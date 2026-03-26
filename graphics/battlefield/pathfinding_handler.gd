class_name PathfindingHandler
extends Node2D



var astar_grid: AStarGrid2D



func setup_astar_2d_grid(p_grid_width: int, p_grid_height: int) -> void:
    astar_grid = AStarGrid2D.new()
    astar_grid.region = Rect2i(0, 0, p_grid_width, p_grid_height)
    astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
    astar_grid.update()


func find_grid_path(p_from_grid_pos: Vector2i, p_to_grid_pos: Vector2i) -> Array[Vector2i]:
    return astar_grid.get_id_path(p_from_grid_pos, p_to_grid_pos)
     