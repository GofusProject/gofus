class_name Dialog
extends Control



signal reponse_button_pressed(player_response_action_resource: ActionResource)
signal cross_button_pressed(leave_dialog_action_resource: ActionResource)

@onready var label: Label = $PanelContainer/MarginContainer/MarginContainer/VBoxContainer/Label
@onready var rich_text_label: RichTextLabel = $PanelContainer/MarginContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichTextLabel
@onready var vbox_container: VBoxContainer = $PanelContainer/MarginContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer
@onready var npc_dialogue_cross_button: TextureButton = $NpcDialogueCrossButton

var buttons: Array[RichTextButton] = [] # to remove | a bon ?
var npc_dialog_theme: Theme



func initialize(p_npc_dialog_theme: Theme) -> void:
	npc_dialogue_cross_button.pressed.connect(func(): cross_button_pressed.emit(ActionResource.new(ActionResource.ActionId.LEAVE)))
	npc_dialog_theme = p_npc_dialog_theme


func update(p_npc_name: String, p_npc_dialog: String, p_player_responses_text: Array[String], p_responses_action_resources: Array[ActionResource]):
	reset()
	label.text = p_npc_name
	rich_text_label.text = p_npc_dialog
	for i in p_player_responses_text.size():
		var rich_text_button: RichTextButton = RichTextButton.new()
		rich_text_button.bbcode_enabled = true
		rich_text_button.custom_minimum_size = Vector2(0, 60.0)
		rich_text_button.theme = npc_dialog_theme
		rich_text_button.text = "[left][ul]" + p_player_responses_text[i] + "[/ul][/left]"

		rich_text_button.pressed.connect(
			func(): reponse_button_pressed.emit(
				ActionResource.new(
					ActionResource.ActionId.RESPOND_TO_NPC,
					p_responses_action_resources[i].action_id,
					p_responses_action_resources[i].param_1)
			)
		)
		buttons.append(rich_text_button)
		vbox_container.add_child(rich_text_button)


func reset():
	for button in buttons:
		button.queue_free()
	buttons.clear()
