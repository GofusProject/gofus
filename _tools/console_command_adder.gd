extends Node
# Linked to Console addon from Jistpoe : https://www.youtube.com/watch?v=M_ymfQtZad4


func _ready() -> void:
	Console.add_command("change_map", console_change_map, 1)
	Console.add_command("display_cell_ids", console_display_cell_ids)
	Console.add_command("tp", console_teleport, 3, 1)


func console_change_map(param: String):
	Game.create_map(int(param))

func console_display_cell_ids():
	Game.battlefield.display_cell_ids()

func console_teleport(map_id: String, cell_id: String = "", character_id: String = ""):
	if character_id == "": character_id = str(Game.characters_manager.get_player_character_resource().id)
	if cell_id == "": cell_id = str(Game.characters_manager.get_player_character_resource().cell_id)
	Game.actions.teleport(int(character_id), int(map_id), int(cell_id))
