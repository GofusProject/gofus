# battlefield.gd
extends Node2D


var map_handler: MapHandler
var character_sprite_handler: CharacterSpriteHandler
var over_head_handler: OverHeadHandler
var grid_handler: GridHandler

const CELL_WIDTH: int = 106
const CELL_HALF_WIDTH: float = 53
const CELL_HEIGHT: int = 54  # Half-height for isometric
const CELL_HALF_HEIGHT: float = 27  # Half-height for isometric
const LEVEL_HEIGHT: int = 40  # Vertical offset per elevation level

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


	background = get_node_or_null("Background")
	ground_layer = get_node_or_null("GroundLayer")
	object1_layer = get_node_or_null("Object1Layer")
	object2_layer = get_node_or_null("Object2Layer")
	interaction_layer = get_node_or_null("InteractionLayer")
	cell_ids_layer = get_node_or_null("CellIDSLayer")
	character_sprites = get_node_or_null("CharacterSprites")
	over_head_layer = get_node_or_null("OverHeadLayer")
	grid_layer = get_node_or_null("GridLayer")

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


func _on_animated_character_sprite_2d_hovered(animated_character_sprite_2d: AnimatedCharacterSprite2D) -> void:
	animated_character_sprite_2d_hovered.emit(animated_character_sprite_2d)


func _on_animated_character_sprite_2d_unhovered(animated_character_sprite_2d: AnimatedCharacterSprite2D) -> void:
	animated_character_sprite_2d_unhovered.emit(animated_character_sprite_2d)


func _on_animated_character_sprite_2d_clicked(animated_character_sprite_2d: AnimatedCharacterSprite2D) -> void:
	animated_character_sprite_2d_clicked.emit(animated_character_sprite_2d)
	print("[Battlefield] sprite_frames_id ", animated_character_sprite_2d.sprite_frames_id, " clicked")

#endregion


#region MapHandler

func render_map(p_background_id, p_cell_visual_resources: Array[CellVisualResource]) -> void:
	print("[Battlefield] Rendering map...")
	var render_start_time : int = Time.get_ticks_usec()

	_clear()
	if background != null and p_background_id != 0:
		map_handler.render_background(p_background_id)
	for cell_visual_resource in p_cell_visual_resources:
		map_handler.render_cell(
			cell_visual_resource.id,
			cell_visual_resource.x, cell_visual_resource.y,
			cell_visual_resource.ground_slope,
			cell_visual_resource.ground_tile_id,
			cell_visual_resource.ground_tile_rot,
			cell_visual_resource.is_ground_tile_flip,
			cell_visual_resource.ground_texture,
			cell_visual_resource.ground_hframes,
			cell_visual_resource.ground_offset,
			cell_visual_resource.object1_id,
			cell_visual_resource.object1_rot,
			cell_visual_resource.is_object1_flip,
			cell_visual_resource.object1_texture,
			cell_visual_resource.object1_offset,
			cell_visual_resource.object2_id,
			cell_visual_resource.is_object2_interactive,
			cell_visual_resource.is_object2_flip,
			cell_visual_resource.object2_texture,
			cell_visual_resource.object2_offset
		)

		grid_handler.render_cell(
			cell_visual_resource.x, cell_visual_resource.y,
			cell_visual_resource.ground_slope
		)

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
