class_name Actions
extends Node



var is_debug_mode: bool = false

# Managers
var map_manager: MapManager
var characters_manager: CharactersManager
var dialog_manager: DialogManager



func initialize(p_map_manager: MapManager, p_characters_manager: CharactersManager, p_dialog_manager: DialogManager) -> void:
	map_manager = p_map_manager
	characters_manager = p_characters_manager
	dialog_manager = p_dialog_manager


func teleport(character_id: int, p_map_id: int, p_cell_id: int = -1) -> void:

	if map_manager.get_current_map_id() != p_map_id && character_id != 0:
		push_error("[Actions] Teleportation failed: cannot teleport character id %d to map id %d because it's an npc)" % [character_id, p_map_id])
		return

	# Map creation if current map id != new map id
	if map_manager.get_current_map_id() != p_map_id:
		create_map_and_characters(p_map_id)

	# Player teleportation
	var world_position = map_manager.get_cell_world_position_from_cell_id(p_cell_id)
	if is_debug_mode: print("[Actions] Teleport player character (character id: %d) to map id %d and cell id %d (world position: %s)" % [character_id, p_map_id, p_cell_id, world_position])
	characters_manager.teleport_character(character_id, world_position, p_cell_id)
	

## If player id != -1, the player is created
func create_map_and_characters(p_map_id: int, p_player_id: int = -1) -> void:

	if map_manager.get_current_map_id() != -1:
		Game.ui.reset()
		characters_manager.clear_characters() # WARNING: Animated sprite are cleared with free() instead of queue_free()
		map_manager.clear_map()

	var is_map_created = map_manager.create_map(p_map_id)
	if not is_map_created:
		push_error("[Game] Map changed failed")
		return

	if p_player_id != -1:
		# Player creation 
		var player_character_id: int = characters_manager.create_player_character(p_player_id)
		if player_character_id != -1:
			var player_character_cell_id = characters_manager.get_character_cell_id(player_character_id)
			var player_world_position = map_manager.get_cell_world_position_from_cell_id(player_character_cell_id)
			characters_manager.teleport_character(player_character_id, player_world_position, player_character_cell_id)
			if is_debug_mode: print("[Game] Player character created with id %d and teleported to cell id %d (world position: %s)" % [player_character_id, player_character_cell_id, player_world_position])
		else:
			push_error("[Game] Player character creation failed")

	# Npcs creation
	var npc_ids: Array[int] = map_manager.get_current_map_npc_ids()

	for npc_id in npc_ids:
		if is_debug_mode: print("[Game] Create NPC character with npc id:", npc_id)
		var npc_character_id: int = characters_manager.create_npc(npc_id)
		if npc_character_id == -1:
			continue
		
		var npc_character_cell_id = characters_manager.get_character_cell_id(npc_character_id)
		var npc_world_position = map_manager.get_cell_world_position_from_cell_id(npc_character_cell_id)
		characters_manager.teleport_character(npc_character_id, npc_world_position, npc_character_cell_id)


func start_dialog_with_npc(p_npc_id: int):
	var map_resource_id: int = map_manager.get_current_map_id()
	var npc_resource = characters_manager.get_character_resource(p_npc_id) as NonPlayableCharacterResource

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

	dialog_manager.start_dialog(npc_init_dialog_question_id, npc_name_with_npc_template_id)


func respond_to_npc(p_action_id: int, p_param: int):
	var action_resource = ActionResource.new(p_action_id, p_param)
	Game.player.execute_action(action_resource)
	if not p_action_id == ActionResource.ActionId.CONTINUE_DIALOG:
		dialog_manager.leave_dialog()


func continue_dialog(p_dialog_question_id) -> void:
	var npc_name: String = dialog_manager.get_dialog_resource().dialog_title
	dialog_manager.continue_dialog(npc_name, p_dialog_question_id)


func leave_dialog():
	dialog_manager.leave_dialog()


func move_playable_character_on_map(to_cell_id: int):
	var character_resource: CharacterResource = characters_manager.get_player_character_resource()
	if is_debug_mode: print("[Actions] Moving character id %d from cell id %d to cell id %d" % [character_resource.id, character_resource.cell_id, to_cell_id])
	var results: Array[Array] = map_manager.get_world_path_and_directions(character_resource.cell_id, to_cell_id)
	var path = results[0]
	var directions = results[1]

	characters_manager.move_character(character_resource, path, directions)
