class_name CellInteractionHandler
extends Node2D


func create_cell_area(world_x: float, world_y: float, ground_slope: int, movement: int) -> void:
	if movement == 0:
		return

	var pos = Vector2(world_x, world_y)
	var cell_area = Area2D.new()
	cell_area.position = pos

	var collision_polygon_2d = CollisionPolygon2D.new()
	var raw = Battlefield.SLOPE_POINTS[ground_slope]
	var points = PackedVector2Array()
	for p in raw:
		points.append(Vector2(p[0] * Battlefield.slope_points_scaling, p[1] * Battlefield.slope_points_scaling))
	collision_polygon_2d.polygon = points

	cell_area.add_child(collision_polygon_2d)
	Battlefield.cell_interaction_layer.add_child(cell_area)


func clear() -> void:
	for child in Battlefield.cell_interaction_layer.get_children():
		child.queue_free()