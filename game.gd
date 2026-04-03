extends Node



var map_id: int = 10354
var player_id: int = 1
var actions: Actions

# Modules
var database
var datacenter
var gofus_translator
var asset_loader
var battlefield
var ui

# Manager
var character_manager
var map_manager
var dialog_manager






func _ready() -> void:
	actions = Actions.new()
	MapManager.scripted_cell_triggered.connect(func(action_resource: ActionResource): execute_action(action_resource))
	change_map(map_id)
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



func execute_action(action_resource: ActionResource) -> void:
	# if action.condition and not action.condition.is_met(character):
	# 	return

	match action_resource.action_id:
		ActionResource.ActionId.TELEPORTATION:
			actions.teleport(Datacenter.player_character_resource.id, action_resource.param_1, action_resource.param_2)


func change_map(p_map_id: int):

	var is_map_created = MapManager.create_map(p_map_id)
	if not is_map_created:
		push_error("[Game] Map changed failed")
		return
	CharactersManager.create_player_character(player_id)
	CharactersManager.create_npcs()
