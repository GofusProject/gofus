# MapHandler.gd
# Equivalent of MapHandler.as
# Node representing a complete map with all visual layers
  
extends Node2D
class_name MapHandler
  

var cell_pointer: Sprite2D

# Object pools - arrays of reusable nodes
var _ground_sprite_pool: Array[Sprite2D] = []
var _object1_sprite_pool: Array[Sprite2D] = []
var _object2_sprite_pool: Array[Sprite2D] = []
var _label_pool: Array[Label] = []
# Pool usage indices (how many from each pool are currently in use)
var _ground_pool_index: int = 0
var _object1_pool_index: int = 0
var _object2_pool_index: int = 0
var _label_pool_index: int = 0
  

func _get_pooled_sprite2D(pool: Array, index: int, layer: Node) -> Sprite2D:
	if index < pool.size():
		var sprite: Sprite2D = pool[index]
		sprite.rotation_degrees = 0.0
		sprite.scale = Vector2.ONE
		sprite.frame = 0
		sprite.visible = true
		return sprite
	else:
		var sprite: Sprite2D = Sprite2D.new()
		sprite.centered = false
		sprite.y_sort_enabled = true
		layer.add_child(sprite)
		pool.append(sprite)
		return sprite


func _get_ground_sprite2D() -> Sprite2D:
	var sprite : Sprite2D = _get_pooled_sprite2D(_ground_sprite_pool, _ground_pool_index, Battlefield.ground_layer)
	_ground_pool_index += 1
	return sprite


func _get_object1_sprite2D() -> Sprite2D:
	var sprite : Sprite2D = _get_pooled_sprite2D(_object1_sprite_pool, _object1_pool_index, Battlefield.object1_layer)
	_object1_pool_index += 1
	return sprite


func _get_object2_sprite2D() -> Sprite2D:
	var sprite : Sprite2D = _get_pooled_sprite2D(_object2_sprite_pool, _object2_pool_index, Battlefield.object2_layer)
	_object2_pool_index += 1
	return sprite


## Get or create a label from the label pool
func _get_cell_id_label() -> Label:
	if _label_pool_index < _label_pool.size():
		var label: Label = _label_pool[_label_pool_index]
		_label_pool_index += 1
		label.visible = true
		return label
	else:
		var label: Label = Label.new()
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 2)
		Battlefield.cell_ids_layer.add_child(label)
		_label_pool.append(label)
		_label_pool_index += 1
		return label


## Reset all pools for reuse (called before render_map)
func _reset_pools() -> void:
	
	# Hide all pooled sprites beyond the current usage
	for i in range(_ground_sprite_pool.size()):
		_ground_sprite_pool[i].visible = false
	
	for i in range(_object1_sprite_pool.size()):
		_object1_sprite_pool[i].visible = false
	
	for i in range(_object2_sprite_pool.size()):
		_object2_sprite_pool[i].visible = false
	
	for i in range(_label_pool.size()):
		_label_pool[i].visible = false
	
	# Reset indices to start from beginning
	_ground_pool_index = 0
	_object1_pool_index = 0
	_object2_pool_index = 0
	_label_pool_index = 0



func render_cell(
	id: int,
	world_x: int, world_y: int,
	ground_slope: int,
	ground_tile_id: int,
	ground_tile_rot: int,
	is_ground_tile_flip: bool,
	object1_id: int,
	object1_rot: int,
	object1_flip: bool,
	object2_id: int,
	is_object2_interactive: bool,
	is_object2_flip: bool,
	) -> void:

	# Ground layer
	if ground_tile_id != 0:
		# ground_tiles += 1
		var ground_sprite: Sprite2D = _get_ground_sprite2D()
		
		var ground_sprite_metadata: Dictionary = AssetLoader.get_ground_sprite_metadata(ground_tile_id)
		ground_sprite.hframes = ground_sprite_metadata["frame_count"]
		ground_sprite.texture = AssetLoader.get_ground_tile_texture(ground_tile_id)
		var bounds: Vector2 = Vector2(
			ground_sprite_metadata["horizontal"],
			ground_sprite_metadata["vertical"]
		)
		
		ground_sprite.offset = bounds
		ground_sprite.position = Vector2(world_x, world_y)

		if ground_slope != 1:
			ground_sprite.frame = ground_slope - 1
		elif ground_tile_rot != 0:
			ground_sprite.rotation_degrees = float(ground_tile_rot * 90)
			if int(ground_sprite.rotation_degrees) % 180 != 0:
				ground_sprite.scale = Vector2(0.5185, 1.9286)

		if is_ground_tile_flip:
			ground_sprite.scale.x *= -1.0
		
	# Object layer 1
	if object1_id != 0:
		# object1_tiles += 1
		var object1_sprite: Sprite2D = _get_object1_sprite2D()
		
		# Reset sprite properties
		object1_sprite.hframes = 1  # Reset frame count
		object1_sprite.texture = AssetLoader.get_object_sprite_texture(object1_id)
		
		var object1_bounds_metadata: Dictionary = AssetLoader.get_object_sprite_metadata(object1_id)
		var bounds: Vector2 = Vector2(
			object1_bounds_metadata["horizontal"],
			object1_bounds_metadata["vertical"]
		)
		
		object1_sprite.offset = bounds
		object1_sprite.position = Vector2(world_x, world_y)

		if ground_slope == 1 and object1_rot != 0:
			object1_sprite.rotation_degrees = float(object1_rot * 90)
			if int(object1_sprite.rotation_degrees) % 180 != 0:
				object1_sprite.scale = Vector2(0.5185, 1.9286)

		if object1_flip:
			object1_sprite.scale.x *= -1.0
		
	# Object layer 2 (top)
	if object2_id != 0:
		# object2_tiles += 1
		var object2_sprite: Sprite2D = _get_object2_sprite2D()
		
		# Reset sprite properties
		object2_sprite.hframes = 1  # Reset frame count
		object2_sprite.texture = AssetLoader.get_object_sprite_texture(object2_id)

		var object2_bounds_metadata: Dictionary = AssetLoader.get_object_sprite_metadata(object2_id)
		var bounds: Vector2 = Vector2(
			object2_bounds_metadata["horizontal"],
			object2_bounds_metadata["vertical"]
		)
		
		object2_sprite.offset = bounds
		object2_sprite.position = Vector2(world_x, world_y) 

		if is_object2_flip:
			object2_sprite.scale.x = -1.0
		
	# Cell ID label
	var cell_id_label: Label = _get_cell_id_label()
	cell_id_label.text = str(id)
	cell_id_label.position = Vector2(world_x, world_y)
	cell_id_label.position.x -= 10  # Approximate centering offset
	cell_id_label.position.y -= 6


## Build full visual representation of the map
func render_map() -> void:

	# TO REMOVE
	var map_resource = Datacenter.current_map_resource
	var cell_resources = map_resource.cell_resources
	

	
	# Background
	if Battlefield.background != null and map_resource.background_id != 0:
		Battlefield.background.texture = AssetLoader.get_background_texture(map_resource.background_id)
  

	for cell_resource in cell_resources:
		render_cell(
			cell_resource.id,
			cell_resource.x,
			cell_resource.y,
			cell_resource.cell_slope,
			cell_resource.ground_tile_id,
			cell_resource.ground_tile_rot,
			cell_resource.is_ground_tile_flip,
			cell_resource.object1_id,
			cell_resource.object1_rot,
			cell_resource.is_object1_flip,
			cell_resource.object2_id,
			cell_resource.is_object2_interactive,
			cell_resource.is_object2_flip
		)

	# TO REMOVE #
	cell_pointer = Sprite2D.new()
	cell_pointer.texture = load("res://assets/graphics/gfx/cell_pointer.png")
	cell_pointer.z_index = 1
	Battlefield.ground_layer.add_child(cell_pointer)
	

func clear_map() -> void:
	# Clear background
	if Battlefield.background != null:
		Battlefield.background.texture = null
	
	# Hide all pooled sprites and labels
	_reset_pools()


## cell world pos -> grid pos 
func get_grid_position_from_world_position(world_pos: Vector2) -> Vector2i:
	# With ground_level = 7, the Y offset cancels out:
	# cell_world_y = row * CELL_HALF_HEIGHT - LEVEL_HEIGHT * (7 - 7)
	#              = row * CELL_HALF_HEIGHT
	var row: int = roundi(world_pos.y / Battlefield.CELL_HALF_HEIGHT)

	# Determine x_offset for this row using the same isometric alternating logic.
	# Even rows have x_offset = 0, odd rows have x_offset = CELL_HALF_WIDTH.
	var x_offset: float = Battlefield.CELL_HALF_WIDTH if row % 2 == 1 else 0.0

	var col: int = roundi((world_pos.x - x_offset) / Battlefield.CELL_WIDTH)

	return Vector2i(col, row)


## grid pos -> cell world pos
func get_cell_world_position_from_grid_position(grid_pos: Vector2i) -> Vector2:
	var x_offset: float = Battlefield.CELL_HALF_WIDTH if grid_pos.y % 2 == 1 else 0.0
	var world_x: float = grid_pos.x * Battlefield.CELL_WIDTH + x_offset
	var world_y: float = grid_pos.y * Battlefield.CELL_HALF_HEIGHT
	return Vector2(world_x, world_y)


## cell id -> cell world pos
func get_cell_world_position_from_cell_id(p_cell_id: int) -> Vector2:
	var cell_resource: CellResource = Datacenter.current_map_resource.cell_resources[p_cell_id]
	var world_pos = Vector2(cell_resource.x, cell_resource.y)
	if world_pos == Vector2.ZERO:
		push_error("[MapHandler] World position cound not be retrieved for cell id ", str(p_cell_id))

	return Vector2(cell_resource.x, cell_resource.y)


## cell world pos -> cell id
func get_cell_id_from_world_position(p_world_position: Vector2, p_cell_resources: Array[CellResource]) -> int:

	for cell_resource in p_cell_resources:
		var cell_rect = Rect2(Vector2(cell_resource.x, cell_resource.y), Vector2(Battlefield.CELL_WIDTH, Battlefield.CELL_HALF_HEIGHT))
		if cell_rect.has_point(p_world_position):
			return cell_resource.id

	push_error("[MapHandler] Cell ID could not be retrieved for world position ", str(p_world_position))
	return -1


func update_cell_pointer_position(p_world_position: Vector2) -> void:
	var grid_pos: Vector2i = get_grid_position_from_world_position(p_world_position) # c'est celle là qui marche pas
	var clamped_world_pos: Vector2 = get_cell_world_position_from_grid_position(grid_pos)
	cell_pointer.position = clamped_world_pos



## Toggle visibility of cell ID labels
func display_cell_ids() -> void:
	if Battlefield.cell_ids_layer:
		Battlefield.cell_ids_layer.visible = not Battlefield.cell_ids_layer.visible
	
