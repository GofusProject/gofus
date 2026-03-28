class_name PathfindingHandler
extends Node2D



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



func setup_astar_2d_grid(p_grid_start: Vector2i, p_grid_size: Vector2i) -> void:
    astar_grid = AStarGrid2D.new()
    astar_grid.region = Rect2i(p_grid_start.x, p_grid_start.y, p_grid_size.x, p_grid_size.y)
    astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
    astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
    astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
    astar_grid.update()

    # the all region is set to solid, then walkability is allow from cell resource movement in Battlefield map init
    # Needs to be called after update()
    astar_grid.fill_solid_region(astar_grid.region) 

func find_grid_path(p_from_grid_pos: Vector2i, p_to_grid_pos: Vector2i) -> Array[Vector2i]:
    return astar_grid.get_id_path(p_from_grid_pos, p_to_grid_pos)


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