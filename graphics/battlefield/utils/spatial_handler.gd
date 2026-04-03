## SpatialHandler uses DIAMOND grid (contrary to MapHandler which use staggered grid)
## Handles directions, pathfinding
## It does not handle any visual process, so it can be transfered easily to server side
## Can be called by any battlefield handler
## Cannot convert diamond grid position to world position because it does not handle slope or cell levels 
## To communicate with other handlers, it can provide cell ids

class_name SpatialHandler
extends Node



enum Direction {
	EAST = 0,
	SOUTH_EAST = 1,
	SOUTH = 2,
	SOUTH_WEST = 3,
	WEST = 4,
	NORTH_WEST = 5,
	NORTH = 6,
	NORTH_EAST = 7
}

var astar_grid: AStarGrid2D



func setup_astar_2d_grid(p_map_staggered_width: int, p_cell_resources: Array[CellResource]) -> void:

	# cell_resource.diamond_grid_pos is calculated from the staggered grid positioning
	var staggered_grid_x: int = -1
	var staggered_grid_y: int = 0
	var max_staggered_grid_x: int = p_map_staggered_width - 1
	var diamond_grid_start = Vector2i(0, 1 - p_map_staggered_width)
	var diamond_grid_size = Vector2i(0, p_map_staggered_width * 2)

	for cell_resource in p_cell_resources:

		# Match staggered grid loop (See MapHandler)
		if staggered_grid_x == max_staggered_grid_x:
			staggered_grid_x = 0
			staggered_grid_y += 1
  
			if max_staggered_grid_x == p_map_staggered_width - 1:
				max_staggered_grid_x -= 1
			else:
				max_staggered_grid_x += 1
		else:
			staggered_grid_x += 1

		# Diamond grid pos. Found those calculation myself
		cell_resource.diamond_grid_position.y = (p_map_staggered_width * staggered_grid_y) - cell_resource.id
		cell_resource.diamond_grid_position.x = cell_resource.id - (p_map_staggered_width - 1) * staggered_grid_y

		# diamond_grid_size.x setting
		# Didn't find a way to calculate map diamond size.x, so for now I take the highest cell ressource diamond grid x
		if cell_resource.diamond_grid_position.x > diamond_grid_size.x: # diamond_grid_size.x
			diamond_grid_size.x = cell_resource.diamond_grid_position.x


	# A* Star setup 
	astar_grid = AStarGrid2D.new()
	astar_grid.region = Rect2i(diamond_grid_start.x, diamond_grid_start.y, diamond_grid_size.x, diamond_grid_size.y)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE # Set to this heuristic so that the path do not zig zag
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	astar_grid.update()


	# Set astar grid walkability based on cell movement property
	astar_grid.fill_solid_region(astar_grid.region) 
	for cell_resource in p_cell_resources:
		if cell_resource.movement != 0:
			astar_grid.set_point_solid(cell_resource.diamond_grid_position, false)


func find_path(p_map_width: int, p_from_cell_id: int, p_to_cell_id: int) -> Array[int]:
	var from_grid_pos: Vector2i = get_grid_pos_from_cell_id(p_map_width, p_from_cell_id)
	var to_grid_pos: Vector2i = get_grid_pos_from_cell_id(p_map_width, p_to_cell_id)

	var grid_path: Array[Vector2i] = astar_grid.get_id_path(from_grid_pos, to_grid_pos)

	var path_cell_ids: Array[int] = []
	for grid_pos: Vector2i in grid_path:
		path_cell_ids.append(get_cell_id_from_grid_pos(p_map_width, grid_pos.x, grid_pos.y))
	return path_cell_ids


func get_direction_from_grid_pos(p_from_grid_pos: Vector2i, p_to_grid_pos: Vector2i) -> int:

	var direction_vector = p_to_grid_pos - p_from_grid_pos
	match direction_vector:
		Vector2i(1, 0):
			return Direction.EAST
		Vector2i(1, 1):
			return Direction.SOUTH_EAST
		Vector2i(0, 1):
			return Direction.SOUTH
		Vector2i(-1, 1):
			return Direction.SOUTH_WEST
		Vector2i(-1, 0):
			return Direction.WEST
		Vector2i(-1, -1):
			return Direction.NORTH_WEST
		Vector2i(0, -1):
			return Direction.NORTH
		Vector2i(1, -1):
			return Direction.NORTH_EAST
		_:
			push_error("[PathfindingHandler] Invalid direction vector: %s" % str(direction_vector))
			return -1


## Only work for adjacents cells
func get_direction_from_cell_id_to_cell_id(p_map_width: int, p_from_cell_id: int, p_to_cell_id: int) -> int:

	var cell_id_offset = p_to_cell_id - p_from_cell_id

	# Godot 4's match statement doesn't allow expressions (like p_map_width * 2 - 1) in patterns — only constants and literals.
	#So I have to use if statements instead of match

	if cell_id_offset == 1:
		return Direction.EAST
	elif cell_id_offset == p_map_width:
		return Direction.SOUTH_EAST
	elif cell_id_offset == p_map_width * 2 - 1:
		return Direction.SOUTH
	elif cell_id_offset == p_map_width - 1:
		return Direction.SOUTH_WEST
	elif cell_id_offset == -1:
		return Direction.WEST
	elif cell_id_offset == -p_map_width:
		return Direction.NORTH_WEST
	elif cell_id_offset == -p_map_width * 2 + 1:
		return Direction.NORTH
	elif cell_id_offset == -(p_map_width - 1):
		return Direction.NORTH_EAST
	else:
		push_error("[PathfindingHandler] Invalid cell id offset: %d" % cell_id_offset)
		return -1


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


func get_cell_neighbours(cell_id: int, p_map_width: int) -> Array:
	var neighbours: Array[int] = []
	for direction in Direction.values():
		var neighbour_cell_id = get_cell_id_at_direction(cell_id, direction, p_map_width)
		if neighbour_cell_id >= 0:
			neighbours.append(neighbour_cell_id)
	return neighbours


func get_cell_id_at_direction(from_cell_id: int, direction: Direction, p_map_width: int) -> int:

	match direction:
		Direction.EAST:
			return from_cell_id + 1
		Direction.SOUTH_EAST:
			return from_cell_id + p_map_width
		Direction.SOUTH:
			return from_cell_id + p_map_width * 2 - 1
		Direction.SOUTH_WEST:
			return from_cell_id + p_map_width - 1
		Direction.WEST:
			return from_cell_id - 1
		Direction.NORTH_WEST:
			return from_cell_id - p_map_width
		Direction.NORTH:
			return from_cell_id - p_map_width * 2 + 1
		Direction.NORTH_EAST:
			return from_cell_id - p_map_width + 1
		_:
			push_error("[SpatialHander] Invalid direction: %s" % str(direction))
			return -1


func clear() -> void:
	astar_grid = null
	for child in Battlefield.debug_astar_layer.get_children():
		child.queue_free()
