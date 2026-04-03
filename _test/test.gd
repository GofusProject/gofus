@tool
extends Node2D


# func _ready() -> void:
# 	var sqlite_db = SQLite.new()
# 	add_child(sqlite_db)

# @export var grid_y: int = 0
# @export var get_grid_pos_from_cell_id_toggle: bool = false:
# 	set(v):
# 		if v and Engine.is_editor_hint():
# 			get_grid_pos_from_cell_id(cell_id)
# 		get_grid_pos_from_cell_id_toggle = false

# @export var get_cell_id_from_staggered_pos_toggle: bool = false:
# 	set(v):
# 		get_cell_id_from_staggered_pos(grid_x, grid_y)
# 		get_grid_pos_from_cell_id_toggle = false

# func _ready() -> void:
# 	print(Database.get_scripted_cells_data(

var animated_sprite_2D

func _ready() -> void:
	animated_sprite_2D = AnimatedSprite2D.new()
	animated_sprite_2D.animation_changed.connect(_on_animation_changed)
	add_child(animated_sprite_2D)
	animated_sprite_2D.sprite_frames = load("res://assets/graphics/characters/9047/9047.tres")

	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.1  # 1 second
	timer.timeout.connect(_on_timer_timeout)
	timer.start()


func _on_animation_changed() -> void:
	print("Anim changed")

func _on_timer_timeout():
	animated_sprite_2D.play("staticR")
