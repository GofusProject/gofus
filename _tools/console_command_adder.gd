extends Node
# Linked to Console addon from Jistpoe : https://www.youtube.com/watch?v=M_ymfQtZad4


func _ready() -> void:
	Console.add_command("change_map", console_change_map, 1)
	Console.add_command("display_cell_ids", console_display_cell_ids)


func console_change_map(param: String):
	Game.change_map(int(param))

func console_display_cell_ids():
	Game.battlefield.display_cell_ids()
