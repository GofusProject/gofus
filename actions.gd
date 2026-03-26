class_name Actions
extends Node



func start_dialog_with_npc(p_npc_id: int):
	var map_resource: MapResource = Datacenter.get_current_map()
	var npc_resource = Datacenter.get_character_resource(p_npc_id) as NonPlayableCharacterResource

	var npc_name: String = npc_resource.name

	# Set npc_init_dialog_id
	var npc_init_dialog_map_to_id: Dictionary[int, int] = npc_resource.init_dialog_map_to_id
	var npc_init_dialog_question_id = -1
	if not npc_init_dialog_map_to_id.has(map_resource.map_id):
		print("[CharactersManager] Map id %s not found in npc init dialog dictionary %s" % [map_resource.map_id, npc_init_dialog_map_to_id])
		npc_init_dialog_question_id = npc_init_dialog_map_to_id[-1]
	else:
		npc_init_dialog_question_id = npc_init_dialog_map_to_id[map_resource.map_id]

	DialogManager.start_dialog(npc_init_dialog_question_id, npc_name)


func respond_to_npc(p_action_id: int, p_param: int):
	var action_resource = ActionResource.new(p_action_id, p_param)
	Player.execute_action(action_resource)
	if not p_action_id == ActionResource.ActionId.CONTINUE_DIALOG:
		DialogManager.leave_dialog()


func continue_dialog(p_dialog_question_id) -> void:
	var npc_name: String = Datacenter.dialog_resource.dialog_title
	DialogManager.continue_dialog(npc_name, p_dialog_question_id)


func leave_dialog():
	DialogManager.leave_dialog()


func move_playable_character_on_map(to_cell_id: int):
	var character_resource: CharacterResource = CharactersManager.get_playable_character_resource()
	var path: Array[Vector2] = MapManager.find_path(character_resource.cell_id, to_cell_id)
	CharactersManager.move_character(character_resource.id, path)