## Equivalent of MapHandler.as
## Node representing a complete map with all visual layers
## Note: Spatial handling is in SpatialHandler

extends Node2D
class_name MapHandler
  


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
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
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


func render_background(p_background_id: int) -> void:
	Battlefield.background.texture = AssetLoader.get_background_texture(p_background_id)


## Called by the Battlefield to render the all map
func render_cell(
	id: int,
	world_x: float, world_y: float,
	grid_x: int, grid_y: int,
	ground_slope: int,
	ground_tile_id: int,
	ground_tile_rot: int,
	is_ground_tile_flip: bool,
	ground_texture: Texture2D,
	ground_hframes: int,
	ground_offset: Vector2,
	object1_id: int,
	object1_rot: int,
	object1_flip: bool,
	object1_texture: Texture2D,
	object1_offset: Vector2,
	object2_id: int,
	is_object2_interactive: bool,
	is_object2_flip: bool,
	object2_texture: Texture2D,
	object2_offset: Vector2
	) -> void:

	# Ground layer
	if ground_tile_id != 0:
		# ground_tiles += 1
		var ground_sprite: Sprite2D = _get_ground_sprite2D()
		ground_sprite.name = "GroundSprite" + str(id)
		
		ground_sprite.hframes = ground_hframes
		ground_sprite.texture = ground_texture

		ground_sprite.offset = ground_offset
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
		object1_sprite.name = "Object1Sprite" + str(id)

		# Reset sprite properties
		object1_sprite.hframes = 1  # Reset frame count
		object1_sprite.texture = object1_texture

		object1_sprite.offset = object1_offset
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
		object2_sprite.name = "Object2Sprite" + str(id)
		
		# Reset sprite properties
		object2_sprite.hframes = 1  # Reset frame count
		object2_sprite.texture = object2_texture
		object2_sprite.offset = object2_offset
		object2_sprite.position = Vector2(world_x, world_y) 

		if is_object2_flip:
			object2_sprite.scale.x = -1.0
		
	# Cell ID label
	var cell_id_label: Label = _get_cell_id_label()
	cell_id_label.text = str(id) + "\n" + str(Vector2i(grid_x, grid_y))

	# Force Godot to compute the minimum size right now
	cell_id_label.reset_size()  # or call size = cell_id_label.get_minimum_size()
	var label_size: Vector2 = cell_id_label.get_minimum_size()
	cell_id_label.position = Vector2(world_x, world_y) - label_size / 2


func render_map(p_background_id, p_map_width: int, p_cell_resources: Array[CellResource]) -> void:
	print("[Battlefield] Rendering map...")
	var render_start_time : int = Time.get_ticks_usec()

	clear()

	if Battlefield.background != null and p_background_id != 0:
		render_background(p_background_id)

	var col: int = -1
	var row: int = 0
	var x_offset: float = 0
	var max_col: int = p_map_width - 1

	for cell_resource in p_cell_resources:

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

		# Map grid positioning
		# Dofus has a different way to calculate this (Pathfinding.as, getCaseCoordonnee(), just before return)
		cell_resource.staggered_grid_y = row
		cell_resource.staggered_grid_x = col

		# World positioning - TO MAP HANDLER
		var cell_world_x: float = col * Battlefield.CELL_WIDTH + x_offset
		var cell_world_y: float = row * Battlefield.CELL_HALF_HEIGHT \
			- Battlefield.LEVEL_HEIGHT * (cell_resource.cell_level - 7)
  
		var cell_position: Vector2 = Vector2(cell_world_x, cell_world_y)
		cell_resource.x = cell_position.x
		cell_resource.y = cell_position.y

		render_cell(
			cell_resource.id,
			cell_resource.x, cell_resource.y,
			cell_resource.diamond_grid_x, cell_resource.diamond_grid_y,
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

		render_grid_cell(
			cell_resource.x, cell_resource.y,
			cell_resource.ground_slope,
			cell_resource.movement
		)


	var render_end_time : int = Time.get_ticks_usec()
	var render_time_sec : float = (render_end_time - render_start_time) / 1_000_000.0
	print("[Battlefield] Map rendered (took %.2f sec)" % render_time_sec)


func render_grid_cell(world_x: float, world_y: float, ground_slope: int, movement: int) -> void:
	if movement == 0:
		return

	var pos = Vector2(world_x, world_y)
	var cell_visual = Line2D.new()
	cell_visual.closed = true
	cell_visual.width = 1.5
	cell_visual.antialiased = true
	cell_visual.position = pos
	var raw = Battlefield.SLOPE_POINTS[ground_slope]
	var points = PackedVector2Array()
	for p in raw:
		points.append(Vector2(p[0] * Battlefield.slope_points_scaling, p[1] * Battlefield.slope_points_scaling))
	cell_visual.points = points
	Battlefield.grid_layer.add_child(cell_visual)


func clear() -> void:
	# Clear background
	if Battlefield.background != null:
		Battlefield.background.texture = null
	
	# Hide all pooled sprites and labels
	_reset_pools()

	# A implementer en pool
	for child in Battlefield.grid_layer.get_children():
		child.queue_free()



## grid pos -> cell world pos
func get_cell_world_position_from_grid_position(grid_pos: Vector2i) -> Vector2:
	var x_offset: float = Battlefield.CELL_HALF_WIDTH if grid_pos.y % 2 == 1 else 0.0
	var world_x: float = grid_pos.x * Battlefield.CELL_WIDTH + x_offset
	var world_y: float = grid_pos.y * Battlefield.CELL_HALF_HEIGHT
	return Vector2(world_x, world_y)


## cell id -> cell world pos
func get_cell_world_position_from_cell_id(p_cell_id: int) -> Vector2:
	var cell_resource: CellResource = Datacenter.map_resource.cell_resources[p_cell_id]
	var world_pos = Vector2(cell_resource.x, cell_resource.y)
	if world_pos == Vector2.ZERO:
		push_error("[MapHandler] World position cound not be retrieved for cell id ", str(p_cell_id))

	return Vector2(cell_resource.x, cell_resource.y)


## cell world pos -> cell id
func get_cell_id_from_world_position(p_world_position: Vector2, p_cell_resources: Array[CellResource]) -> int:

	for cell_resource in p_cell_resources:
		if p_world_position == Vector2(cell_resource.x, cell_resource.y):
			print("[MapHandler] Cell ID %s found for world pos %s" % [cell_resource.id, str(p_world_position)])
			return cell_resource.id

	push_error("[MapHandler] Cell ID could not be retrieved for world position ", str(p_world_position))
	return -1
