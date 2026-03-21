class_name DialogResource
extends Resource



var dialog_question_id: int
var player_response_ids: Array[int] = []

var params # Pour afficher du texte, ex : param = [bankCost], text = [...] chaque consultation de votre compte vous coûtera #1 Kamas.
var cond
var if_false: int
var player_response_action_resources: Array[ActionResource] = []

var dialog_title: String
var dialog_question_text: String
var player_response_texts: Array[String]  = []



func _init(p_dialog_question_data: Dictionary, p_dialog_question_text: String, p_dialog_title: String) -> void:
	dialog_question_id = int(p_dialog_question_data["id"])
	dialog_title = p_dialog_title
	dialog_question_text = p_dialog_question_text
	params = p_dialog_question_data["params"]
	cond = p_dialog_question_data["cond"]
	if_false = int(p_dialog_question_data["if_false"])

	# Parse player_response_ids
	if p_dialog_question_data["player_response_ids"] == "":
		pass
	else:
		var player_response_string_ids: PackedStringArray = p_dialog_question_data["player_response_ids"].split(";")
		for id_str in player_response_string_ids:
			player_response_ids.append(id_str.to_int())


func initialize_response(p_player_response_data: Dictionary, p_player_response_text: String) -> void:
	var action_resource = ActionResource.new((int(p_player_response_data["type"])), int(p_player_response_data["args"]))
	player_response_action_resources.append(action_resource)
	player_response_texts.append(p_player_response_text)
