extends Node2D



# @export var ground_level: int = 7:   # Uniform ground level (slope ignored)
# 	set(v):
# 		ground_level = v
# 		queue_redraw()

# # @export var tile_fill_color: Color = Color(0.15, 0.55, 0.85, 0.25)
# var tile_outline_color: Color = Color(1, 1, 1, 0.3)
# var tile_outline_width: float = 1.5
# var show_cell_index: bool = false


# func _draw() -> void:
# 	var col: int = -1
# 	var row: int = 0
# 	var x_offset: float = 0.0

# 	var map_resource = Datacenter.current_map_resource
# 	var cell_resources: Array[CellResource] = map_resource.cell_resources
# 	var cell_count: int = cell_resources.size()
# 	var max_col: int = map_resource.width - 1

# 	var cell_id: int = -1
# 	while cell_id + 1 < cell_count:
# 		cell_id += 1

# 		var cell_resource: CellResource = cell_resources[cell_id]

# 		if col == max_col:
# 			col = 0
# 			row += 1

# 			if x_offset == 0.0:
# 				x_offset = Battlefield.CELL_HALF_WIDTH
# 				max_col -= 1
# 			else:
# 				x_offset = 0.0
# 				max_col += 1
# 		else:
# 			col += 1

# 		# --- World positioning ---
# 		var cell_world_x: float = col * Battlefield.CELL_WIDTH + x_offset
# 		var cell_world_y: float = row * Battlefield.CELL_HALF_HEIGHT \
# 			- Battlefield.LEVEL_HEIGHT * (cell_resource.ground_level - 7)

# 		var cell_center := Vector2(cell_world_x, cell_world_y)

# 		_draw_iso_tile(cell_center, cell_id)


# ## Draws a single isometric diamond tile centered at `center`.
# func _draw_iso_tile(center: Vector2, index: int) -> void:
# 	# Diamond vertices: top, right, bottom, left
# 	var top    := center + Vector2(0,               -Battlefield.CELL_HALF_HEIGHT)
# 	var right  := center + Vector2(Battlefield.CELL_HALF_WIDTH,  0)
# 	var bottom := center + Vector2(0,                Battlefield.CELL_HALF_HEIGHT)
# 	var left   := center + Vector2(-Battlefield.CELL_HALF_WIDTH, 0)

# 	var diamond := PackedVector2Array([top, right, bottom, left])

# 	# Fill
# 	# draw_colored_polygon(diamond, tile_fill_color)

# 	# Outline (draw each edge individually for clean line width control)
# 	draw_line(top,    right,  tile_outline_color, tile_outline_width)
# 	draw_line(right,  bottom, tile_outline_color, tile_outline_width)
# 	draw_line(bottom, left,   tile_outline_color, tile_outline_width)
# 	draw_line(left,   top,    tile_outline_color, tile_outline_width)

# 	# Optional cell index label
# 	if show_cell_index:
# 		draw_string(
# 			ThemeDB.fallback_font,
# 			center + Vector2(-6, 5),
# 			str(index),
# 			HORIZONTAL_ALIGNMENT_LEFT,
# 			-1,
# 			10,
# 			Color.WHITE
# 		)