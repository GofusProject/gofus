@tool
extends Node2D

## Isometric Grid Drawer
## Replicates the cell loop positioning logic, drawing the grid as diamond tiles.

# --- Constants (mirror your Battlefield constants) ---
const CELL_WIDTH: float = 64.0
const CELL_HALF_WIDTH: float = CELL_WIDTH / 2.0
const CELL_HEIGHT: float = 32.0
const CELL_HALF_HEIGHT: float = CELL_HEIGHT / 2.0
const LEVEL_HEIGHT: float = 16.0
const DEFAULT_GROUND_LEVEL: int = 7  # Baseline level; offsets to 0 world-Y shift

# --- Inspector config ---
@export var cell_count: int = 25:
	set(v):
		cell_count = v
		queue_redraw()

@export var ground_level: int = 7:   # Uniform ground level (slope ignored)
	set(v):
		ground_level = v
		queue_redraw()

# @export var tile_fill_color: Color = Color(1, 1, 1, 0.25)
@export var tile_outline_color: Color = Color(1, 1, 1, 0.9)
@export var tile_outline_width: float = 1.5
@export var show_cell_index: bool = true


func _draw() -> void:
	# Reproduce the original loop state
	var col: int = 0
	var row: int = 0
	var x_offset: float = 0.0

	# Derive starting max_col from cell_count.
	# The original grid expands: row 0 has N cols, row 1 has N-1, row 2 has N, etc.
	# We need to figure out what max_col was at the start.
	# Assume a square-ish diamond: max_col starts at ceil(sqrt(cell_count)).
	var max_col: int = ceili(sqrt(float(cell_count)))

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

		_draw_iso_tile(cell_center, cell_id)


## Draws a single isometric diamond tile centered at `center`.
func _draw_iso_tile(center: Vector2, index: int) -> void:
	# Diamond vertices: top, right, bottom, left
	var top    := center + Vector2(0,               -CELL_HALF_HEIGHT)
	var right  := center + Vector2(CELL_HALF_WIDTH,  0)
	var bottom := center + Vector2(0,                CELL_HALF_HEIGHT)
	var left   := center + Vector2(-CELL_HALF_WIDTH, 0)

	var diamond := PackedVector2Array([top, right, bottom, left])

	# Fill
	# draw_colored_polygon(diamond, tile_fill_color)

	# Outline (draw each edge individually for clean line width control)
	draw_line(top,    right,  tile_outline_color, tile_outline_width)
	draw_line(right,  bottom, tile_outline_color, tile_outline_width)
	draw_line(bottom, left,   tile_outline_color, tile_outline_width)
	draw_line(left,   top,    tile_outline_color, tile_outline_width)

	# Optional cell index label
	if show_cell_index:
		draw_string(
			ThemeDB.fallback_font,
			center + Vector2(-6, 5),
			str(index),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			10,
			Color.WHITE
		)