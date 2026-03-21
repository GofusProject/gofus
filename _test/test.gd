@tool
extends Node2D


@export var npc_template_data_init_question: String
@export var parse_dialog: bool = false:
	set(v):
		if v and Engine.is_editor_hint():
			# dialog_parsing()
			pass
		parse_dialog = false


func _ready() -> void:
	var string = "7"
	var player_response_string_ids: PackedStringArray = string.split(";")
	print(player_response_string_ids)
	print(player_response_string_ids.size())