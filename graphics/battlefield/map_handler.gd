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


## Build full visual representation of the map
func render_map() -> void:
	
	var col: int = -1
	var row: int = 0
	var x_offset: float = 0
  
	var map_resource = Datacenter.current_map_resource
	var cell_resources: Array[CellResource] = map_resource.cell_resources
	var cell_count: int = cell_resources.size()
	var max_col: int = map_resource.width - 1
	
	# Counters for statistics
	var active_cells: int = 0
	var ground_tiles: int = 0
	var object1_tiles: int = 0
	var object2_tiles: int = 0
	
	# Background
	if Battlefield.background != null and map_resource.background_id != 0:
		Battlefield.background.texture = AssetLoader.get_background_texture(map_resource.background_id)
  
	# Cell loop
	var cell_id: int = -1
	while cell_id + 1 < cell_count:
		cell_id += 1
  
		var cell_resource: CellResource = cell_resources[cell_id]

		# Grid positioning (isometric logic)
		if col == max_col:
			col = 0
			row += 1
  
			if x_offset == 0:
				x_offset = Battlefield.CELL_HALF_WIDTH
				max_col -= 1
			else:
				x_offset = 0
				max_col += 1
		else:
			col += 1
  
		# World positioning
		var cell_world_x: float = col * Battlefield.CELL_WIDTH + x_offset
		var cell_world_y: float = row * Battlefield.CELL_HALF_HEIGHT \
			- Battlefield.LEVEL_HEIGHT * (cell_resource.ground_level - 7)
  
		var cell_position: Vector2 = Vector2(cell_world_x, cell_world_y)
		cell_resource.x = cell_position.x
		cell_resource.y = cell_position.y

		if not cell_resource.active:
			continue
		
		active_cells += 1
  
		# Ground layer
		if cell_resource.layer_ground_num != 0:
			ground_tiles += 1
			var ground_sprite: Sprite2D = _get_ground_sprite2D()
			
			var ground_sprite_metadata: Dictionary = AssetLoader.get_ground_sprite_metadata(cell_resource.layer_ground_num)
			ground_sprite.hframes = ground_sprite_metadata["frame_count"]
			ground_sprite.texture = AssetLoader.get_ground_tile_texture(cell_resource.layer_ground_num)
			var bounds: Vector2 = Vector2(
				ground_sprite_metadata["horizontal"],
				ground_sprite_metadata["vertical"]
			)
			
			ground_sprite.offset = bounds
			ground_sprite.position = cell_position
  
			if cell_resource.ground_slope != 1:
				ground_sprite.frame = cell_resource.ground_slope - 1
			elif cell_resource.layer_ground_rot != 0:
				ground_sprite.rotation_degrees = float(cell_resource.layer_ground_rot * 90)
				if int(ground_sprite.rotation_degrees) % 180 != 0:
					ground_sprite.scale = Vector2(0.5185, 1.9286)
  
			if cell_resource.layer_ground_flip:
				ground_sprite.scale.x *= -1.0
			
		# Object layer 1
		if cell_resource.layer_object1_num != 0:
			object1_tiles += 1
			var object1_sprite: Sprite2D = _get_object1_sprite2D()
			
			# Reset sprite properties
			object1_sprite.hframes = 1  # Reset frame count
			object1_sprite.texture = AssetLoader.get_object_sprite_texture(cell_resource.layer_object1_num)
			
			var object1_bounds_metadata: Dictionary = AssetLoader.get_object_sprite_metadata(cell_resource.layer_object1_num)
			var bounds: Vector2 = Vector2(
				object1_bounds_metadata["horizontal"],
				object1_bounds_metadata["vertical"]
			)
			
			object1_sprite.offset = bounds
			object1_sprite.position = cell_position
  
			if cell_resource.ground_slope == 1 and cell_resource.layer_object1_rot != 0:
				object1_sprite.rotation_degrees = float(cell_resource.layer_object1_rot * 90)
				if int(object1_sprite.rotation_degrees) % 180 != 0:
					object1_sprite.scale = Vector2(0.5185, 1.9286)
  
			if cell_resource.layer_object1_flip:
				object1_sprite.scale.x *= -1.0
			
		# Object layer 2 (top)
		if cell_resource.layer_object2_num != 0:
			object2_tiles += 1
			var object2_sprite: Sprite2D = _get_object2_sprite2D()
			
			# Reset sprite properties
			object2_sprite.hframes = 1  # Reset frame count
			object2_sprite.texture = AssetLoader.get_object_sprite_texture(cell_resource.layer_object2_num)

			var object2_bounds_metadata: Dictionary = AssetLoader.get_object_sprite_metadata(cell_resource.layer_object2_num)
			var bounds: Vector2 = Vector2(
				object2_bounds_metadata["horizontal"],
				object2_bounds_metadata["vertical"]
			)
			
			object2_sprite.offset = bounds
			object2_sprite.position = cell_position 
  
			if cell_resource.layer_object2_flip:
				object2_sprite.scale.x = -1.0
			
		# Cell ID label
		var cell_id_label: Label = _get_cell_id_label()
		cell_id_label.text = str(cell_id)
		cell_id_label.position = cell_position
		cell_id_label.position.x -= 10  # Approximate centering offset
		cell_id_label.position.y -= 6

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
			return cell_resource.cell_id

	push_error("[MapHandler] Cell ID could not be retrieved for world position ", str(p_world_position))
	return -1


func update_cell_pointer_position(p_local_position: Vector2) -> void:
	var grid_pos: Vector2i = get_grid_position_from_world_position(p_local_position)
	var clamped_world_pos: Vector2 = get_cell_world_position_from_grid_position(grid_pos)
	cell_pointer.position = clamped_world_pos


## Toggle visibility of cell ID labels
func display_cell_ids() -> void:
	if Battlefield.cell_ids_layer:
		Battlefield.cell_ids_layer.visible = not Battlefield.cell_ids_layer.visible
	
