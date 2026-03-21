extends Node



var map_id: int = 10354
var player_id: int = 1



func _ready() -> void:
	change_map(map_id)
	create_player(player_id)
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_F12:
			get_tree().quit()
	
	if event.is_action_pressed("ui_right"):
			map_id += 1
			change_map(map_id)

	if event.is_action_pressed("ui_left"):
			map_id -= 1
			change_map(map_id)




func change_map(p_map_id: int):
	Ui.reset()
	CharactersManager.clear_characters()
	MapManager.clear_map()

	var is_map_created = MapManager.create_map(p_map_id)
	if not is_map_created:
		push_error("[Game] Map changed failed")
		return
	CharactersManager.create_npcs()


func create_player(p_player_id) -> void:
	CharactersManager.create_playable_character(p_player_id)
