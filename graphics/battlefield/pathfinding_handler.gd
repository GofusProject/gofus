class_name PathfindingHandler
extends Node2D



var astar_grid: AStarGrid2D



func setup_astar_2d_grid(grid_width: int, grid_height: int) -> void:
    var astar_grid = AStarGrid2D.new()
    astar_grid.region = Rect2i(0, 0, grid_width, grid_height)
    astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
    astar_grid.update()


func get_grid_path(from_grid_pos: Vector2i, to_grid_pos: Vector2i) -> void:
    print(astar_grid.get_id_path(from_grid_pos, to_grid_pos))