class_name GridHandler
extends Node2D


const CELL_SCENE: PackedScene = preload("res://graphics/battlefield/scenes/Cell.tscn")
## Isometric Grid Drawer
## Replicates the cell loop positioning logic, drawing the grid as diamond tiles.
# func draw_grid() -> void:
# 	Battlefield.grid_layer.queue_redraw()

func draw_grid() -> void:
	var col: int = -1
	var row: int = 0
	var x_offset: float = 0.0

	var map_resource = Datacenter.current_map_resource
	var cell_resources: Array[CellResource] = map_resource.cell_resources
	var cell_count: int = cell_resources.size()
	var max_col: int = map_resource.width - 1

	var cell_id: int = -1
	while cell_id + 1 < cell_count:
		cell_id += 1

		var cell_resource: CellResource = cell_resources[cell_id]

		if col == max_col:
			col = 0
			row += 1

			if x_offset == 0.0:
				x_offset = Battlefield.CELL_HALF_WIDTH
				max_col -= 1
			else:
				x_offset = 0.0
				max_col += 1
		else:
			col += 1

		# --- World positioning ---
		var cell_world_x: float = col * Battlefield.CELL_WIDTH + x_offset
		var cell_world_y: float = row * Battlefield.CELL_HALF_HEIGHT \
			- Battlefield.LEVEL_HEIGHT * (cell_resource.cell_level - 7)

		var cell_center := Vector2(cell_world_x, cell_world_y)

		var cell: Cell = CELL_SCENE.instantiate()
		cell.id = cell_resource.id
		cell.position = cell_center
		Battlefield.grid_layer.add_child(cell)
