@tool
extends Node2D

@export var draw_test: Node2D


const CELL_POINT_POS: Array = [
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


@export var cell_point_pos_id: int = 1
@export var create_grid_toggle: bool = false:
	set(v):
		if v and Engine.is_editor_hint():
			for child in draw_test.get_children():
				child.free()
			create_line(Vector2(500, 500))
		create_grid_toggle = false



# --- Constants (mirror your Battlefield constants) ---
const CELL_WIDTH: int = 106
const CELL_HALF_WIDTH: float = 53
const CELL_HEIGHT: int = 54  # Half-height for isometric
const CELL_HALF_HEIGHT: float = 27  # Half-height for isometric
const LEVEL_HEIGHT: int = 40  # Vertical offset per elevation level
const DEFAULT_GROUND_LEVEL: int = 7  # Baseline level; offsets to 0 world-Y shift

# --- Inspector config ---
@export var cell_count: int = 25:
	set(v):
		cell_count = v
		create_grid()

@export var ground_level: int = 7:   # Uniform ground level (slope ignored)
	set(v):
		ground_level = v


func create_grid() -> void:
	for child in draw_test.get_children():
		child.free()

	# Reproduce the original loop state
	var col: int = 0
	var row: int = 0
	var x_offset: float = 0.0

	var max_col: int = 15

	var cell_id: int = -1
	while cell_id + 1 < cell_count:
		cell_id += 1

		# --- Grid positioning (mirror of original isometric logic) ---
		if col == max_col:
			col = 0
			row += 1

			if x_offset == 0.0:
				x_offset = CELL_HALF_WIDTH
				max_col -= 1
			else:
				x_offset = 0.0
				max_col += 1
		else:
			col += 1

		# --- World positioning ---
		var cell_world_x: float = col * CELL_WIDTH + x_offset
		var cell_world_y: float = row * CELL_HALF_HEIGHT \
			- LEVEL_HEIGHT * (ground_level - 7)

		var cell_center := Vector2(cell_world_x, cell_world_y)

		create_line(cell_center)




func create_line(cell_center) -> void:
	if cell_point_pos_id <= 0 or cell_point_pos_id >= CELL_POINT_POS.size():
		push_warning("Invalid cell_point_pos_id: %d" % cell_point_pos_id)
		return
	
	var visual_cell = Line2D.new()
	visual_cell.closed = true
	visual_cell.width = 1.5
	visual_cell.antialiased = true
	visual_cell.position = cell_center
	var raw = CELL_POINT_POS[cell_point_pos_id]
	var points = PackedVector2Array()
	for p in raw:
		points.append(Vector2(p[0] * 2, p[1] * 2))
	visual_cell.points = points
	draw_test.add_child(visual_cell)