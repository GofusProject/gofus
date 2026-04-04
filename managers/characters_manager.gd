## Manager responsible for handling character data and interactions in the game.
## It serves as a central point for managing character resources, including playable characters and NPCs,
class_name CharactersManager
extends Node



signal character_world_path_point_reached(world_pos: Vector2, linked_character_id: int)

var is_debug_mode: bool = false

# Modules
var database: Database
var datacenter: Datacenter
var gofus_translator: GofusTranslator
var asset_loader: AssetLoader
var battlefield: Battlefield
var ui: UI


func initialize(p_database: Database,
	p_datacenter: Datacenter,
	p_gofus_translator: GofusTranslator,
	p_asset_loader: AssetLoader,
	p_battlefield: Battlefield,
	p_ui: UI) -> void:

	database = p_database
	datacenter = p_datacenter
	gofus_translator = p_gofus_translator
	asset_loader = p_asset_loader
	battlefield = p_battlefield
	ui = p_ui


func setup_signals() -> void:
	battlefield.character_sprite_handler.character_world_path_point_reached.connect(_on_battlefield_character_world_path_point_reached)


func create_player_character(p_player_id: int) -> int:

	var player_data = database.get_player_data(p_player_id)
	if player_data.is_empty():
		push_error("[Game] Player data empty for player id %d" % p_player_id)
		return -1

	var player_character_resource = PlayerCharacterResource.new(player_data)

	player_character_resource.sprite_frames = asset_loader.get_character_sprite_frames(player_character_resource.sprite_frames_id)

	# Metadata (offsets...)
	var character_sprite_metadata: Dictionary = asset_loader.get_character_sprite_metadata(player_character_resource.sprite_frames_id)
	var character_sprite_metadata_resources: Dictionary[String, SpriteMetadataResource] = {}
	for key in character_sprite_metadata.keys():
		var sprite_metadata_resource = SpriteMetadataResource.new(character_sprite_metadata[key])
		character_sprite_metadata_resources[key] = sprite_metadata_resource
	player_character_resource.sprite_metadata_resources = character_sprite_metadata_resources

	# Added in datacenter in both player_character_resource and character_resources[]
	datacenter.player_character_resource = player_character_resource
	var player_character_id = datacenter.add_character_resource(player_character_resource)


	battlefield.character_sprite_handler.add_animated_character_sprite_2d(
		player_character_id,
		player_character_resource.sprite_frames,
		player_character_resource.sprite_metadata_resources,
		player_character_resource.direction,
		true
	)

	return player_character_id


func create_npc(p_npc_id: int) -> int:

	var npc_data: Dictionary = database.get_npc_data(p_npc_id)
	if npc_data.is_empty():
		push_error("[CharacterManager] Npc data empty for npc id %s" % p_npc_id)
		return -1

	var npc_template_data = database.get_npc_template_data(int(npc_data.npc_template_id))
	if npc_template_data.is_empty():
		push_error("[CharacterManager] Npc template data empty for npc template id %s" % npc_data.npc_template_id)
		return -1


	var npc_template_name = gofus_translator.get_npc_template_name(int(npc_data.npc_template_id))
	if npc_template_name.is_empty():
		push_error("[CharacterManager] Npc template lang data empty for npc template lang id %s" % npc_data.npc_template_id)
		return -1

	var non_playable_character_resource = NonPlayableCharacterResource.new(npc_data, npc_template_data, npc_template_name)

	# Sprite frame
	non_playable_character_resource.sprite_frames = asset_loader.get_character_sprite_frames(non_playable_character_resource.sprite_frames_id)

	# Metadata (offsets...)
	var character_sprite_metadata: Dictionary = asset_loader.get_character_sprite_metadata(non_playable_character_resource.sprite_frames_id)
	var character_sprite_metadata_resources: Dictionary[String, SpriteMetadataResource] = {}
	for key in character_sprite_metadata.keys():
		var sprite_metadata_resource = SpriteMetadataResource.new(character_sprite_metadata[key])
		character_sprite_metadata_resources[key] = sprite_metadata_resource
	non_playable_character_resource.sprite_metadata_resources = character_sprite_metadata_resources

	var character_id: int = datacenter.add_character_resource(non_playable_character_resource)

	# Rendering
	battlefield.character_sprite_handler.add_animated_character_sprite_2d(
		character_id,
		non_playable_character_resource.sprite_frames,
		non_playable_character_resource.sprite_metadata_resources,
		non_playable_character_resource.direction
	)

	return character_id


func clear_characters() -> void:
	datacenter._character_resources.clear()
	# Player character is readded because its persistance.  
	datacenter.add_character_resource(datacenter.player_character_resource)
	battlefield.character_sprite_handler.clear()
	ui.close_character_popup_menu()


func get_character_resource(p_character_id) -> CharacterResource:
	return datacenter.get_character_resource(p_character_id)


func get_player_character_resource() -> PlayerCharacterResource:
	return datacenter.player_character_resource


func get_character_cell_id(p_character_id: int) -> int:
	return datacenter.get_character_resource(p_character_id).cell_id


func move_character(p_character_resource: CharacterResource, p_path: Array[Vector2], p_orientations: Array[CharacterSpriteHandler.Orientation]) -> void:
	battlefield.character_sprite_handler.move_character(p_character_resource.id, p_path, p_orientations)


func teleport_character(p_character_id: int, p_world_position: Vector2, p_cell_id: int) -> void:
	if is_debug_mode: print("[CharactersManager] Teleport character id %d to cell id %d (world position: %s)" % [p_character_id, p_cell_id, p_world_position])
	battlefield.character_sprite_handler.teleport_character(p_character_id, p_world_position)
	
	# Update character cell id
	var character_resource = datacenter.get_character_resource(p_character_id)
	character_resource.cell_id = p_cell_id
	
	

#region UI

func show_character_over_head(character_id: int) -> void:
	var character_resource: CharacterResource = datacenter.get_character_resource(character_id)
	battlefield.show_character_over_head(character_id, character_resource.name)


func hide_character_over_head() -> void:
	battlefield.hide_character_over_head()


func open_character_popup_menu(p_character_id: int) -> void:
	ui.close_character_popup_menu()

	var character_resource = datacenter.get_character_resource(p_character_id)

	# Match can't handle "character_resource is NonPlayableCharacterResource"
	if character_resource is NonPlayableCharacterResource:
		var npc_interaction_ids: Array[int] = character_resource.interaction_ids
		var npc_interaction_texts: Array[String] = []
		for npc_interaction_id in npc_interaction_ids:
			var interaction_text = gofus_translator.get_npc_interaction_text(npc_interaction_id)
			npc_interaction_texts.append(interaction_text)
		var npc_interaction_data: Array[Dictionary] = []
		for i in npc_interaction_ids.size():
			npc_interaction_data.append({
				"id": npc_interaction_ids[i],
				"name": npc_interaction_texts[i]
			})
		ui.open_npc_popup_menu(npc_interaction_data)

	elif character_resource is PlayableCharacterResource:
		ui.close_character_popup_menu()


func close_character_popup_menu() -> void:
	ui.close_character_popup_menu()


#endregion



#region Battlefied

func _on_battlefield_character_world_path_point_reached(world_pos: Vector2, linked_character_id: int) -> void:
	character_world_path_point_reached.emit(world_pos, linked_character_id)

#endregion
