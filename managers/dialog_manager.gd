extends Node



func start_dialog(p_init_dialog_question_id: int, p_dialog_title: String) -> void:
	var dialog_resource: DialogResource = _create_dialog_resource(p_dialog_title, p_init_dialog_question_id)
	if dialog_resource == null:
		Ui.open_dialog(p_dialog_title, "", [], [])
		return

	Datacenter.dialog_resource = dialog_resource
	Ui.open_dialog(p_dialog_title, dialog_resource.dialog_question_text, dialog_resource.player_response_texts, dialog_resource.player_response_action_resources)


func continue_dialog(p_dialog_title: String, p_dialog_question_id: int) -> void:
	var dialog_resource: DialogResource = _create_dialog_resource(p_dialog_title, p_dialog_question_id)
	if dialog_resource == null:
		Ui.update_dialog(p_dialog_title, "", [], [])
		return

	Datacenter.dialog_resource = dialog_resource
	Ui.update_dialog(p_dialog_title, dialog_resource.dialog_question_text, dialog_resource.player_response_texts, dialog_resource.player_response_action_resources)


func leave_dialog() -> void:
	Datacenter.dialog_resource = null
	Ui.close_dialog()


func _create_dialog_resource(p_dialog_title: String, p_dialog_question_id: int) -> DialogResource:
	# Create npc_dialog_resource from p_dialog_question_id
	var dialog_question_data: Dictionary = Database.get_dialog_question_data(p_dialog_question_id)
	var dialog_question_lang: Dictionary = GofusTranslator.get_npc_dialog_lang(p_dialog_question_id)
	if dialog_question_data.is_empty() or dialog_question_lang.is_empty():
		print("[CharactersManager] Npc init dialog data or lang is empty for id ", p_dialog_question_id)
		return null

	var dialog_resource: DialogResource = DialogResource.new(dialog_question_data, dialog_question_lang, p_dialog_title)


	# Add player_response_texts
	for player_response_id in dialog_resource.player_response_ids:
		var player_response_data = Database.get_dialog_response_action_data(player_response_id)
		var player_response_lang = GofusTranslator.get_npc_dialog_player_response_lang(player_response_id)
		if player_response_data.is_empty() or player_response_lang.is_empty():
			printerr("[CharactersManager] Player response dictionary or lang is empty for id ", player_response_id)
			continue

		dialog_resource.initialize_response(player_response_data, player_response_lang)

	return dialog_resource
