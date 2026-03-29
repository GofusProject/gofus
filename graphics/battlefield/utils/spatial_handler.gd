class_name SpatialHandler
extends Node



var astar_2d: AStar2D



func initialize(p_cell_resources: Array[CellResource]) -> void:

	print("[SpatialHandler] Initialize...")
	var render_start_time : int = Time.get_ticks_usec()

	astar_2d = AStar2DExtended.new()
	astar_2d.heuristic = AStar2DExtended.Heuristic.HEURISTIC_OCTILE

	for cell_resource in p_cell_resources:

		if cell_resource.movement != 0:
			astar_2d.add_point(
				cell_resource.id,
				Vector2(cell_resource.x, cell_resource.y)
			)
			var red_square = Polygon2D.new()
			red_square.color = Color.RED
			var square_size = 16
			var square_vertices = PackedVector2Array([
				Vector2(0,0),
				Vector2(square_size,0),
				Vector2(square_size,square_size),
				Vector2(0,square_size)
			])
			red_square.polygon = square_vertices
			Battlefield.debug_astar_layer.add_child(red_square)
			red_square.position = Vector2(cell_resource.x, cell_resource.y) - Vector2(square_size, square_size) / 2

			for neighbour_id in cell_resource.neighbour_cell_ids:
				astar_2d.connect_points(cell_resource.id, neighbour_id)
				var red_line = Line2D.new()
				red_line.default_color = Color.RED
				red_line.width = 2.0
				var line_vertices = PackedVector2Array([
					Vector2(cell_resource.x, cell_resource.y),
					Vector2(Datacenter.map_resource.cell_resources[neighbour_id].x, Datacenter.map_resource.cell_resources[neighbour_id].y)
					])
				red_line.points = line_vertices
				Battlefield.debug_astar_layer.add_child(red_line)
		

	# UNCOMMENT TO RECOVER ASTAR
	# _setup_astar_2d_grid(p_map_diamond_grid_start, p_map_diamond_size)

	# # Set astar grid walkability based on cell movement cost
	# for cell_resource in p_cell_resources:
	# 	if cell_resource.movement != 0:
	# 		pathfinding_handler.astar_grid.set_point_solid(Vector2i(cell_resource.diamond_grid_x, cell_resource.diamond_grid_y), false)


	var render_end_time : int = Time.get_ticks_usec()
	var render_time_sec : float = (render_end_time - render_start_time) / 1_000_000.0
	print("[Battlefield] Map rendered (took %.2f sec)" % render_time_sec)



func find_grid_path(p_from_cell_id: int, p_to_cell_id: int) -> PackedInt64Array:
	return astar_2d.get_id_path(p_from_cell_id, p_to_cell_id)


## cell id -> grid pos
func get_grid_pos_from_cell_id(p_map_width: int, cell_id: int) -> Vector2i:
	@warning_ignore("integer_division")
	var row: int = cell_id / (p_map_width * 2 - 1) 
	var remainder: int = cell_id - row * (p_map_width * 2 - 1)
	var col: int = remainder % p_map_width

	var y: int = row - col
	@warning_ignore("integer_division")
	var x: int = (cell_id - (p_map_width - 1) * y) / p_map_width 

	return Vector2i(x, y)


## grid pos -> cell id
func get_cell_id_from_grid_pos(p_map_width: int, grid_x: int, grid_y: int) -> int:
	return grid_x * p_map_width + grid_y * (p_map_width - 1)



func get_cell_neighbours() -> Array:
	return [] # TO IMPLEMENT
	

func clear() -> void:
	astar_2d = null
	for child in Battlefield.debug_astar_layer.get_children():
		child.queue_free()
