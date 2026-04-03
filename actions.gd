class_name Actions
extends Node



func teleport(character_id: int, p_map_id: int, p_cell_id: int = -1) -> void:

	if MapManager.get_current_map_id() != p_map_id:
		Game.ui.reset()
		CharactersManager.clear_characters()
		MapManager.clear_map()

		var is_map_created = MapManager.create_map(p_map_id)
		if not is_map_created:
			push_error("[Actions] Teleport failed")
			return
		CharactersManager.create_npcs()
	
	var world_position = MapManager.get_cell_world_position_from_cell_id(p_cell_id)
	CharactersManager.teleport_character(character_id, world_position, p_cell_id)


func start_dialog_with_npc(p_npc_id: int):
	var map_resource_id: int = MapManager.get_current_map_id()
	var npc_resource = CharactersManager.get_character_resource(p_npc_id) as NonPlayableCharacterResource

	var npc_name: String = npc_resource.name
	var npc_name_with_npc_template_id: String = npc_name + " (" + str(npc_resource.npc_template_id) + ")"

	# Set npc_init_dialog_id
	var npc_init_dialog_map_to_id: Dictionary[int, int] = npc_resource.init_dialog_map_to_id
	var npc_init_dialog_question_id = -1
	if not npc_init_dialog_map_to_id.has(map_resource_id):
		print("[Actions] Map id %s not found in npc init dialog dictionary %s" % [map_resource_id, npc_init_dialog_map_to_id])
		npc_init_dialog_question_id = npc_init_dialog_map_to_id[-1]
	else:
		npc_init_dialog_question_id = npc_init_dialog_map_to_id[map_resource_id]

	DialogManager.start_dialog(npc_init_dialog_question_id, npc_name_with_npc_template_id)


func respond_to_npc(p_action_id: int, p_param: int):
	var action_resource = ActionResource.new(p_action_id, p_param)
	Player.execute_action(action_resource)
	if not p_action_id == ActionResource.ActionId.CONTINUE_DIALOG:
		DialogManager.leave_dialog()


func continue_dialog(p_dialog_question_id) -> void:
	var npc_name: String = DialogManager.get_dialog_resource().dialog_title
	DialogManager.continue_dialog(npc_name, p_dialog_question_id)


func leave_dialog():
	DialogManager.leave_dialog()


func move_playable_character_on_map(to_cell_id: int):
	var character_resource: CharacterResource = CharactersManager.get_player_character_resource()
	var results: Array[Array] = MapManager.get_world_path_and_directions(character_resource.cell_id, to_cell_id)
	var path = results[0]
	var directions = results[1]

	CharactersManager.move_character(character_resource, path, directions)
