# gapi.as equivalent
class_name UI
extends Control


signal interaction(action_resource: ActionResource)
# to remove
signal gofus_popup_menu_button_pressed(interation_id: int)
signal npc_dialog_reponse_button_pressed(player_response_id: int)
signal npc_dialog_cross_button_pressed()


# Themes
const GOFUS_POPUP_MENU_THEME: Theme = preload("res://assets/popup_menu_theme.tres")
const NPC_DIALOG_THEME: Theme = preload("res://assets/npc_dialog_theme.tres")
# Scenes
const GOFUS_POPUP_MENU_SCENE = preload("res://graphics/ui/scenes/gofus_popup_menu.tscn")
const NPC_DIALOG_SCENE = preload("res://graphics/ui/scenes/dialog_scene.tscn")

# Layers
@onready var gofus_popup_menu_layer: Control = $GofusPopupMenuLayer
@onready var dialog: Dialog = $Dialog
@onready var grid_label_x: Label = $VBoxContainer/GridLabel
@onready var grid_label_y: Label = $VBoxContainer/GridLabel2
@onready var cell_id: Label = $VBoxContainer/GridLabel3


func _ready() -> void:
	dialog.initialize(NPC_DIALOG_THEME)

	dialog.reponse_button_pressed.connect(func(player_response_action_resource: ActionResource): interaction.emit(player_response_action_resource))
	dialog.cross_button_pressed.connect(func(leave_dialog_action_resource: ActionResource): interaction.emit(leave_dialog_action_resource))



func reset() -> void:
	close_character_popup_menu()
	close_dialog()


func open_npc_popup_menu(npc_interaction_data: Array[Dictionary]):
	var gofus_popup_menu: GofusPopupMenu = GOFUS_POPUP_MENU_SCENE.instantiate()
	gofus_popup_menu_layer.add_child(gofus_popup_menu)
	gofus_popup_menu.initialize(npc_interaction_data, GOFUS_POPUP_MENU_THEME)
	gofus_popup_menu.position = get_global_mouse_position()
	gofus_popup_menu.button_pressed.connect(func(interaction_id): gofus_popup_menu_button_pressed.emit(interaction_id))
	

func close_character_popup_menu() -> void:
	for child in gofus_popup_menu_layer.get_children():
		child.queue_free()


func open_dialog(p_dialog_name: String, p_dialog_question_text: String, p_dialog_response_texts: Array[String], p_action_resources: Array[ActionResource]) -> void:
	reset()
	dialog.visible = true
	dialog.update(p_dialog_name, p_dialog_question_text, p_dialog_response_texts, p_action_resources)


func update_dialog(p_dialog_name: String, p_dialog_question_text: String, p_dialog_response_texts: Array[String], p_action_resources: Array[ActionResource]) -> void:
	dialog.update(p_dialog_name, p_dialog_question_text, p_dialog_response_texts, p_action_resources)


func close_dialog() -> void:
	dialog.visible = false
