class_name GridHandler
extends Node2D



func render_cell(world_x: float, world_y: float, ground_slope: int, movement: int) -> void:
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
	for child in Battlefield.grid_layer.get_children():
		child.queue_free()