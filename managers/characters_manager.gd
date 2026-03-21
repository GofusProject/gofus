## Manager responsible for handling character data and interactions in the game.
## It serves as a central point for managing character resources, including playable characters and NPCs,

extends Node



signal character_hovered(character_id: int)
signal character_unhovered(character_id: int)
signal character_clicked(character_id: int)



func _ready() -> void:
	Battlefield.animated_character_sprite_2d_hovered.connect(_on_battlefield_animated_character_sprite_2d_hovered)
	Battlefield.animated_character_sprite_2d_unhovered.connect(_on_battlefield_animated_character_sprite_2d_unhovered)
	Battlefield.animated_character_sprite_2d_clicked.connect(_on_battlefield_animated_character_sprite_2d_clicked)


func create_npcs() -> void:

	var map_resource = Datacenter.get_current_map()
	var npc_ids: Array[int] = map_resource.npc_ids
	clear_characters()

	for npc_id in npc_ids:

		var npc_data: Dictionary = Database.get_npc_data(npc_id)
		if npc_data.is_empty():
			push_error("[CharacterManager] Npc data empty for npc id %d" % npc_id)
			return

		var npc_template_data = Database.get_npc_template_data(int(npc_data.npc_template_id))
		if npc_template_data.is_empty():
			push_error("[CharacterManager] Npc template data empty for npc template id %d" % npc_data.npc_template_id)
			return


		var npc_template_name = GofusTranslator.get_npc_template_name(int(npc_data.npc_template_id))
		if npc_template_name.is_empty():
			push_error("[CharacterManager] Npc template lang data empty for npc template lang id %d" % npc_data.npc_template_id)
			return

		var non_playable_character_resource = NonPlayableCharacterResource.new(npc_data, npc_template_data, npc_template_name)
		var character_id: int = Datacenter.add_character_resource(non_playable_character_resource)

		Battlefield.render_character_sprite(
			character_id,
			non_playable_character_resource.sprite_frames_id,
			non_playable_character_resource.direction,
			non_playable_character_resource.cell_id)


func clear_characters() -> void:
	Datacenter._character_resources.clear()
	Battlefield.clear_character_sprites()
	Ui.close_character_popup_menu()



#region UI

func show_character_over_head(character_id: int) -> void:
	var character_resource: CharacterResource = Datacenter.get_character_resource(character_id)
	Battlefield.show_character_over_head(character_id, character_resource.name)


func hide_character_over_head() -> void:
	Battlefield.hide_character_over_head()


func open_character_popup_menu(p_character_id: int) -> void:
	Ui.close_character_popup_menu()

	var npc_interaction_ids: Array[int] = Datacenter.get_character_resource(p_character_id).interaction_ids
	var npc_interaction_texts: Array[String] = []
	for npc_interaction_id in npc_interaction_ids:
		var interaction_text = GofusTranslator.get_npc_interaction_text(npc_interaction_id)
		npc_interaction_texts.append(interaction_text)

	var npc_interaction_data: Array[Dictionary] = []
	for i in npc_interaction_ids.size():
		npc_interaction_data.append({
			"id": npc_interaction_ids[i],
			"name": npc_interaction_texts[i]
		})

	Ui.open_npc_popup_menu(npc_interaction_data)


func close_character_popup_menu() -> void:
	Ui.close_character_popup_menu()


#endregion



#region Battlefied

func _on_battlefield_animated_character_sprite_2d_hovered(animated_character_sprite_2d: AnimatedCharacterSprite2D) -> void:
	character_hovered.emit(animated_character_sprite_2d.linked_character_id)


func _on_battlefield_animated_character_sprite_2d_unhovered(animated_character_sprite_2d: AnimatedCharacterSprite2D) -> void:
	character_unhovered.emit(animated_character_sprite_2d.linked_character_id)


func _on_battlefield_animated_character_sprite_2d_clicked(animated_character_sprite_2d: AnimatedCharacterSprite2D) -> void:
	character_clicked.emit(animated_character_sprite_2d.linked_character_id)

#endregion
