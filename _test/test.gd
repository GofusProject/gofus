@tool
extends Node2D


var map_width: int = 15
@export var cell_id: int = 0
@export var grid_x: int = 0
@export var grid_y: int = 0
@export var get_grid_pos_from_cell_id_toggle: bool = false:
	set(v):
		if v and Engine.is_editor_hint():
			get_grid_pos_from_cell_id(cell_id)
		get_grid_pos_from_cell_id_toggle = false

@export var get_cell_id_from_staggered_pos_toggle: bool = false:
	set(v):
		get_cell_id_from_staggered_pos(grid_x, grid_y)
		get_grid_pos_from_cell_id_toggle = false



# MapHandler.getCaseNum
func get_cell_id_from_staggered_pos(p_grid_x: int, p_grid_y: int) -> void:
	print(p_grid_x * map_width + p_grid_y * (map_width - 1))

# Pathfinding.getCaseNum
func get_cell_id_from_diamond_pos(p_grid_x: int, p_grid_y: int) -> void:
	print(p_grid_x * map_width + p_grid_y * (map_width - 1))


# Pathfinding.getCaseCoordonnee
func get_grid_pos_from_cell_id(p_cell_id: int) -> void:
	@warning_ignore("integer_division")
	var row: int = p_cell_id / (map_width * 2 - 1) 
	var remainder: int = p_cell_id - row * (map_width * 2 - 1)
	var col: int = remainder % map_width

	var y: int = row - col
	@warning_ignore("integer_division")
	var x: int = (p_cell_id - (map_width - 1) * y) / map_width 

	print(Vector2i(x, y))