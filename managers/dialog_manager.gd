extends Node



# Modules
var database: Database
var datacenter: Datacenter
# var gofus_translator: GofusTranslator
# var asset_loader: AssetLoader
# var battlefield: Battlefield
# var ui: UI


func initialize(p_database: Database, p_datacenter: Datacenter) -> void:
	database = p_database
	datacenter = p_datacenter


func start_dialog(p_init_dialog_question_id: int, p_dialog_title: String) -> void:
	var dialog_resource: DialogResource = _create_dialog_resource(p_dialog_title, p_init_dialog_question_id)
	if dialog_resource == null:
		Ui.open_dialog(p_dialog_title, "", [], [])
		return

	datacenter.dialog_resource = dialog_resource
	Ui.open_dialog(p_dialog_title, dialog_resource.dialog_question_text, dialog_resource.player_response_texts, dialog_resource.player_response_action_resources)


func continue_dialog(p_dialog_title: String, p_dialog_question_id: int) -> void:
	var dialog_resource: DialogResource = _create_dialog_resource(p_dialog_title, p_dialog_question_id)
	if dialog_resource == null:
		Ui.update_dialog(p_dialog_title, "", [], [])
		return

	datacenter.dialog_resource = dialog_resource
	Ui.update_dialog(p_dialog_title, dialog_resource.dialog_question_text, dialog_resource.player_response_texts, dialog_resource.player_response_action_resources)


func leave_dialog() -> void:
	datacenter.dialog_resource = null
	Ui.close_dialog()


func get_dialog_resource() -> DialogResource:
	return datacenter.dialog_resource


func _create_dialog_resource(p_dialog_title: String, p_dialog_question_id: int) -> DialogResource:
	# Create npc_dialog_resource from p_dialog_question_id
	var dialog_question_data: Dictionary = database.get_dialog_question_data(p_dialog_question_id)
	var dialog_question_lang: String = GofusTranslator.get_dialog_question_text(p_dialog_question_id)
	if dialog_question_data.is_empty() or dialog_question_lang.is_empty():
		print("[CharactersManager] Npc init dialog data or lang is empty for id ", p_dialog_question_id)
		return null

	var dialog_resource: DialogResource = DialogResource.new(dialog_question_data, dialog_question_lang, p_dialog_title)


	# Add player_response_texts
	for player_response_id in dialog_resource.player_response_ids:
		var player_response_data = database.get_dialog_response_action_data(player_response_id)
		var player_response_text = GofusTranslator.get_dialog_response_text(player_response_id)
		if player_response_data.is_empty() or player_response_text == "":
			printerr("[CharactersManager] Player response dictionary or lang is empty for id ", player_response_id)
			continue

		dialog_resource.initialize_response(player_response_data, player_response_text)

	return dialog_resource
