class_name PathfindingHandler
extends Node2D



var astar_grid: AStarGrid2D



func setup_astar_2d_grid(p_grid_start: Vector2i, p_grid_size: Vector2i) -> void:
    astar_grid = AStarGrid2D.new()
    astar_grid.region = Rect2i(p_grid_start.x, p_grid_start.y, p_grid_size.x, p_grid_size.y)
    astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
    astar_grid.update()


func find_grid_path(p_from_grid_pos: Vector2i, p_to_grid_pos: Vector2i) -> Array[Vector2i]:
    return astar_grid.get_id_path(p_from_grid_pos, p_to_grid_pos)