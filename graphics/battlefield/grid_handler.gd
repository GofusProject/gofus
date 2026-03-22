class_name GridHandler
extends Node2D


const CELL_SCENE: PackedScene = preload("res://graphics/battlefield/scenes/Cell.tscn")
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


func render_cell(world_x: float, world_y: float, ground_slope: int) -> void:
	var pos = Vector2(world_x, world_y)
	var visual_cell = Line2D.new()
	visual_cell.closed = true
	visual_cell.width = 1.5
	visual_cell.antialiased = true
	visual_cell.position = pos
	var raw = SLOPE_POINTS[ground_slope]
	var points = PackedVector2Array()
	for p in raw:
		points.append(Vector2(p[0] * 2, p[1] * 2))
	visual_cell.points = points
	Battlefield.grid_layer.add_child(visual_cell)


func clear() -> void:
	for child in Battlefield.grid_layer.get_children():
		child.queue_free()