class_name CellInteractionHandler
extends Node2D



# Pool of inactive Area2D nodes ready for reuse
var _area_pool: Array[Area2D] = []
var _area_pool_index: int = 0



func create_cell_area(p_world_position: Vector2, ground_slope: int, movement: int, cell_id: int) -> void:
	if movement == 0:
		return

	# get_pooled_area
	var cell_area: Area2D

	if _area_pool_index >= _area_pool.size():
		cell_area = Area2D.new()
		cell_area.monitoring = false
		cell_area.monitorable = false

		var collision_polygon_2d = CollisionPolygon2D.new()
		collision_polygon_2d.name = "CollisionPolygon2D"
		cell_area.add_child(collision_polygon_2d)

		_area_pool.append(cell_area)
		Battlefield.cell_interaction_layer.add_child(cell_area)
	else:
		cell_area = _area_pool[_area_pool_index] as Area2D
		cell_area.process_mode = Node.PROCESS_MODE_INHERIT

	_area_pool_index += 1

	# Init
	cell_area.position = p_world_position
	cell_area.name = "Area2D" + str(cell_id)

	# Bind signals carrying the live cell_id
	cell_area.mouse_entered.connect(func() -> void: Battlefield.cell_hovered.emit(cell_id))
	cell_area.mouse_exited.connect(func() -> void: Battlefield.cell_unhovered.emit(cell_id))
	cell_area.input_event.connect(func(viewport, event, shape_idx) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			Battlefield.cell_clicked.emit(cell_id)
	)

	# Configure collision polygon
	var collision_polygon_2d = cell_area.get_node("CollisionPolygon2D") as CollisionPolygon2D
	var raw = Battlefield.SLOPE_POINTS[ground_slope]
	var points : PackedVector2Array = PackedVector2Array()
	for p in raw:
		points.append(Vector2(p[0] * Battlefield.slope_points_scaling, p[1] * Battlefield.slope_points_scaling))
	collision_polygon_2d.polygon = points

	


func clear() -> void:
	for cell_area: Area2D in Battlefield.cell_interaction_layer.get_children():
		# Disconnect all signals so the next acquire starts clean
		for connection in cell_area.mouse_entered.get_connections():
			cell_area.mouse_entered.disconnect(connection.callable)
		for connection in cell_area.mouse_exited.get_connections():
			cell_area.mouse_exited.disconnect(connection.callable)
		for connection in cell_area.input_event.get_connections():
			cell_area.input_event.disconnect(connection.callable)

		var collision_polygon_2d = cell_area.get_node("CollisionPolygon2D") as CollisionPolygon2D
		collision_polygon_2d.polygon = []
		cell_area.process_mode = Node.PROCESS_MODE_DISABLED
	
	_area_pool_index = 0
