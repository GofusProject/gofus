@tool
extends Node2D



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

func _ready() -> void:
	print(Database.get_scripted_cells_data(