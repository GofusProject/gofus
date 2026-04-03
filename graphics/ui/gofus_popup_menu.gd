class_name GofusPopupMenu
extends Control


signal button_pressed(intercation_id: int)

var interaction_order = [3, 2, 1, 6, 5, 4, 7, 8]
var gofus_popup_menu_theme: Theme

@onready var vbox_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer


func initialize(p_npc_interaction_data: Array[Dictionary], p_gofus_popup_menu_theme: Theme) -> void:

	p_npc_interaction_data.sort_custom(custom_sort)
	gofus_popup_menu_theme = p_gofus_popup_menu_theme

	for i in p_npc_interaction_data.size():
		var button = Button.new()
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.theme = gofus_popup_menu_theme
		button.text = p_npc_interaction_data[i]["name"]
		button.pressed.connect(func():button_pressed.emit(p_npc_interaction_data[i]["id"]))
		vbox_container.add_child(button)



func custom_sort(a, b):
	var a_index = interaction_order.find(a["id"])
	var b_index = interaction_order.find(b["id"])
	return a_index < b_index