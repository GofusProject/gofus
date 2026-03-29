# battlefield.gd
extends Node2D



signal cell_clicked(cell_id: int)
signal cell_hovered(cell_id: int)
signal cell_unhovered(cell_id: int)

var map_handler: MapHandler
var character_sprite_handler: CharacterSpriteHandler
var over_head_handler: OverHeadHandler
var grid_handler: GridHandler
var cell_interaction_handler: CellInteractionHandler
var pathfinding_handler: PathfindingHandler

# Cell
const CELL_WIDTH: int = 106
const CELL_HALF_WIDTH: float = 53
const CELL_HEIGHT: int = 54  # Half-height for isometric
const CELL_HALF_HEIGHT: float = 27  # Half-height for isometric
const LEVEL_HEIGHT: int = 40  # Vertical offset per elevation level

# Slope
var slope_points_scaling: int = 2 # ! They are multiplied by 2 to match asset scaling 
const SLOPE_POINTS: Array = [ 
	[],
	[[-26.5,0],[0,-13.5],[26.5,0],[0,13.5]],
	[[-26.5,-20],[0,-13.5],[26.5,0],[0,13.5]],
	[[-26.5,0],[0,-33.5],[26.5,0],[0,13.5]],
	[[-26.5,-20],[0,-33.5],[26.5,0],[0,13.5]],
	[[-26.5,0],[0,-13.5],[26.5,-20],[0,13.5]],
	[[-26.5,-20],[0,-13.5],[26.5,-20],[0,13.5]],
	[[-26.5,0],[0,-33.5],[26.5,-20],[0,13.5]],
	[[-26.5,-20],[0,-33.5],[26.5,-20],[0,13.5]],
	[[-26.5,0],[0,-13.5],[26.5,0],[0,-6.5]],
	[[-26.5,-20],[0,-13.5],[26.5,0],[0,-6.5]],
	[[-26.5,0],[0,-33.5],[26.5,0],[0,-6.5]],
	[[-26.5,-20],[0,-33.5],[26.5,0],[0,-6.5]],
	[[-26.5,0],[0,-13.5],[26.5,-20],[0,-6.5]],
	[[-26.5,-20],[0,-13.5],[26.5,-20],[0,-6.5]],
	[[-26.5,0],[0,-33.5],[26.5,-20],[0,-6.5]]
]

# Layers
var background: Sprite2D
var ground_layer: Node2D
var object1_layer: Node2D
var object2_layer: Node2D
var interaction_layer: Node2D
var cell_ids_layer: Node2D
var character_sprites: Node2D
var over_head_layer: Node2D
var grid_layer: Node2D
var cell_interaction_layer: Node2D
var debug_astar_layer: Node2D

var astar_2d: AStar2D

const ANIMATED_CHARACTER_SPRITE_2D_SCENE: PackedScene = preload("res://graphics/battlefield/scenes/AnimatedCharacterSprite2D.tscn")
const TEXT_OVER_HEAD_SCENE: PackedScene = preload("res://graphics/battlefield/scenes/TextOverHead.tscn")

signal animated_character_sprite_2d_hovered(animated_character_sprite_2d: AnimatedCharacterSprite2D)
signal animated_character_sprite_2d_unhovered(animated_character_sprite_2d: AnimatedCharacterSprite2D)
signal animated_character_sprite_2d_clicked(animated_character_sprite_2d: AnimatedCharacterSprite2D)



## Initializes dependencies and event listening
func _ready() -> void:

	map_handler = MapHandler.new()
	character_sprite_handler = CharacterSpriteHandler.new()
	over_head_handler = OverHeadHandler.new()
	grid_handler = GridHandler.new()
	cell_interaction_handler = CellInteractionHandler.new()
	pathfinding_handler = PathfindingHandler.new()

	background = get_node_or_null("Background")
	ground_layer = get_node_or_null("GroundLayer")
	object1_layer = get_node_or_null("Object1Layer")
	object2_layer = get_node_or_null("Object2Layer")
	interaction_layer = get_node_or_null("InteractionLayer")
	cell_ids_layer = get_node_or_null("CellIDSLayer")
	character_sprites = get_node_or_null("CharacterSprites")
	over_head_layer = get_node_or_null("OverHeadLayer")
	grid_layer = get_node_or_null("GridLayer")
	cell_interaction_layer = get_node_or_null("CellInteractionLayer")
	debug_astar_layer = get_node_or_null("DebugAStarLayer")

	background.centered = false


#region CharacterSpriteHandler

func render_character_sprite(p_linked_character_id: int, p_sprite_frames_id: int, p_direction: int, p_cell_id: int) -> void:
	print("[Battlefield] Rendering character...")
	var render_start_time : int = Time.get_ticks_usec()
	character_sprite_handler.add_animated_character_sprite_2d(p_linked_character_id, p_sprite_frames_id, p_direction, p_cell_id)
	var render_end_time : int = Time.get_ticks_usec()
	var render_time_sec : float = (render_end_time - render_start_time) / 1_000_000.0
	print("[Battlefield] Character rendered (took %.2f sec)" % render_time_sec)


func get_character_sprite_world_position(p_character_id: int) -> Vector2:
	return character_sprite_handler.get_animated_character_sprite_2d_world_position(p_character_id)


func clear_character_sprites() -> void:
	character_sprite_handler.clear_character_sprites()


func move_character(p_character_id: int, p_path: Array[Vector2]) -> void:
	character_sprite_handler.move_character(p_character_id, p_path)


func _on_animated_character_sprite_2d_hovered(animated_character_sprite_2d: AnimatedCharacterSprite2D) -> void:
	animated_character_sprite_2d_hovered.emit(animated_character_sprite_2d)


func _on_animated_character_sprite_2d_unhovered(animated_character_sprite_2d: AnimatedCharacterSprite2D) -> void:
	animated_character_sprite_2d_unhovered.emit(animated_character_sprite_2d)


func _on_animated_character_sprite_2d_clicked(animated_character_sprite_2d: AnimatedCharacterSprite2D) -> void:
	animated_character_sprite_2d_clicked.emit(animated_character_sprite_2d)
	print("[Battlefield] sprite_frames_id ", animated_character_sprite_2d.sprite_frames_id, " clicked")

#endregion


#region MapHandler

func render_map(p_background_id, p_cell_resources: Array[CellResource], p_map_diamond_grid_start: Vector2i, p_map_diamond_size: Vector2i) -> void:
	print("[Battlefield] Rendering map...")
	var render_start_time : int = Time.get_ticks_usec()

	_clear()
	astar_2d = AStar2DExtended.new()
	astar_2d.heuristic = AStar2DExtended.Heuristic.HEURISTIC_OCTILE

	if background != null and p_background_id != 0:
		map_handler.render_background(p_background_id)
	for cell_resource in p_cell_resources:
		map_handler.render_cell(
			cell_resource.id,
			cell_resource.x, cell_resource.y,
			cell_resource.staggered_grid_x, cell_resource.staggered_grid_y,
			cell_resource.ground_slope,
			cell_resource.ground_tile_id,
			cell_resource.ground_tile_rot,
			cell_resource.is_ground_tile_flip,
			cell_resource.ground_texture,
			cell_resource.ground_hframes,
			cell_resource.ground_offset,
			cell_resource.object1_id,
			cell_resource.object1_rot,
			cell_resource.is_object1_flip,
			cell_resource.object1_texture,
			cell_resource.object1_offset,
			cell_resource.object2_id,
			cell_resource.is_object2_interactive,
			cell_resource.is_object2_flip,
			cell_resource.object2_texture,
			cell_resource.object2_offset
		)

		grid_handler.render_cell(
			cell_resource.x, cell_resource.y,
			cell_resource.ground_slope,
			cell_resource.movement
		)

		cell_interaction_handler.create_cell_area(
			cell_resource.x, cell_resource.y,
			cell_resource.ground_slope,
			cell_resource.movement,
			cell_resource.id
		)

		if cell_resource.movement != 0:
			astar_2d.add_point(
				cell_resource.id,
				Vector2(cell_resource.x, cell_resource.y)
			)
			var red_square = Polygon2D.new()
			red_square.color = Color.RED
			var square_size = 16
			var square_vertices = PackedVector2Array([
				Vector2(0,0),
				Vector2(square_size,0),
				Vector2(square_size,square_size),
				Vector2(0,square_size)
			])
			red_square.polygon = square_vertices
			debug_astar_layer.add_child(red_square)
			red_square.position = Vector2(cell_resource.x, cell_resource.y) - Vector2(square_size, square_size) / 2

			for neighbour_id in cell_resource.neighbour_cell_ids:
				astar_2d.connect_points(cell_resource.id, neighbour_id)
				var red_line = Line2D.new()
				red_line.default_color = Color.RED
				red_line.width = 2.0
				var line_vertices = PackedVector2Array([
					Vector2(cell_resource.x, cell_resource.y),
					Vector2(Datacenter.map_resource.cell_resources[neighbour_id].x, Datacenter.map_resource.cell_resources[neighbour_id].y)
					])
				red_line.points = line_vertices
				debug_astar_layer.add_child(red_line)
		

	# UNCOMMENT TO RECOVER ASTAR
	# _setup_astar_2d_grid(p_map_diamond_grid_start, p_map_diamond_size)

	# # Set astar grid walkability based on cell movement cost
	# for cell_resource in p_cell_resources:
	# 	if cell_resource.movement != 0:
	# 		pathfinding_handler.astar_grid.set_point_solid(Vector2i(cell_resource.diamond_grid_x, cell_resource.diamond_grid_y), false)


	var render_end_time : int = Time.get_ticks_usec()
	var render_time_sec : float = (render_end_time - render_start_time) / 1_000_000.0
	print("[Battlefield] Map rendered (took %.2f sec)" % render_time_sec)


func clear_map() -> void:
	map_handler.clear_map()


func get_world_position_from_cell_id(cell_id: int) -> Vector2i:
	return map_handler.get_cell_world_position_from_cell_id(cell_id)


func get_cell_id_from_world_position(p_cell_resources: Array[CellResource]) -> int:
	return map_handler.get_cell_id_from_world_position(get_local_mouse_position(), p_cell_resources)


func highlight_cell() -> void:
	map_handler.update_cell_pointer_position(get_local_mouse_position())


func display_cell_ids() -> void:
	map_handler.display_cell_ids()

#endregion


#region PathfindingHandler

func _setup_astar_2d_grid(p_map_diamond_start: Vector2i, p_map_diamond_size: Vector2i) -> void:
	pathfinding_handler.setup_astar_2d_grid(p_map_diamond_start, p_map_diamond_size)


# func find_grid_path(p_from_cell_grid_pos: Vector2i, p_to_cell_grid_pos: Vector2i) -> Array[Vector2i]:
# 	return pathfinding_handler.find_grid_path(p_from_cell_grid_pos, p_to_cell_grid_pos)


func find_grid_path(p_from_cell_id: int, p_to_cell_id: int) -> PackedInt64Array:
	return astar_2d.get_id_path(p_from_cell_id, p_to_cell_id)

#endregion



#region OverHeadHandler

func show_character_over_head(p_character_id: int, p_name: String) -> void:
	var animated_character_sprite_2d: AnimatedCharacterSprite2D = character_sprite_handler.get_animated_character_sprite_2d_by_character_id(p_character_id)
	over_head_handler.create_over_head(animated_character_sprite_2d, p_name)


func hide_character_over_head() -> void:
	over_head_handler.destroy_all_over_head()


#endregion


func _clear() -> void:
	hide_character_over_head()
	clear_map()
	clear_character_sprites()
	grid_handler.clear()
	cell_interaction_handler.clear()
	astar_2d = null
	for child in debug_astar_layer.get_children():
		child.queue_free()
