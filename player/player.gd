extends Node


# Peut-être que ça va être mis dans ActionResource ?
enum NpcInteractions {
	BUY_SELL = 1,
	TRADE = 2,
	TALK = 3,
	DROP_PICK_UP_PET = 4,
	SELL = 5,
	BUY = 6,
	RESURRECT_PET = 7,
	TRADE_MOUNT = 8
}

var coloring_helper: ColoringHelper
var selected_npc_id: int = -1

@onready var dialog_actions: Actions = Actions.new()



func _ready() -> void:
	Ui.interaction.connect(func(p_action_resource): execute_action(p_action_resource))
	Ui.gofus_popup_menu_button_pressed.connect(_on_gofus_popup_menu_button_pressed) # to remove
	# Ui.npc_dialog_reponse_button_pressed.connect(_on_npc_dialog_reponse_button_pressed) # to remove
	# Ui.npc_dialog_cross_button_pressed.connect(_on_npc_dialog_cross_button_pressed) # to remove
	CharactersManager.character_hovered.connect(_on_character_hovered)		# TODO: Battlfield should relay mouse input here
	CharactersManager.character_unhovered.connect(_on_character_unhovered)
	CharactersManager.character_clicked.connect(_on_character_clicked)
	coloring_helper = ColoringHelper.new()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("_unhandled_input pressed")
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("left")
			CharactersManager.close_character_popup_menu()


func execute_action(action_resource: ActionResource) -> void:
	# if action.condition and not action.condition.is_met(character):
	# 	return

	match action_resource.action_id:
		ActionResource.DialogActionId.START:
			dialog_actions.start_dialog_with_npc(selected_npc_id)
		ActionResource.DialogActionId.RESPOND_TO_NPC:
			dialog_actions.respond_to_npc(action_resource.param_1, action_resource.param_2) # param_1 = npc_dialog_player_response_id
		ActionResource.DialogActionId.CONTINUE_DIALOG:
			dialog_actions.continue_dialog(action_resource.param_1) # param_1 = npc_dialog_question_id
		ActionResource.DialogActionId.LEAVE:
			dialog_actions.leave_dialog()
			selected_npc_id = -1
		_:
			printerr("[Player] Action %s not handled !" % action_resource.action_id )
			dialog_actions.leave_dialog()



#region Battlefield

func _on_character_hovered(character_id: int) -> void:
	CharactersManager.show_character_over_head(character_id)
	# coloring_helper.print_color_data(character_id)


func _on_character_unhovered(character_id: int) -> void:
	CharactersManager.hide_character_over_head()
	# print("[Player] Character id ", character_id, " unhovered")


func _on_character_clicked(character_id: int) -> void:
	CharactersManager.open_character_popup_menu(character_id)
	selected_npc_id = character_id

# endregion


#region UI

func _on_gofus_popup_menu_button_pressed(npc_interaction_id: int) -> void:
	match npc_interaction_id:
		NpcInteractions.BUY_SELL:
			print("BUY_SELL")
		NpcInteractions.TRADE:
			print("TRADE")
		NpcInteractions.TALK:
			dialog_actions.start_dialog_with_npc(selected_npc_id)
		NpcInteractions.DROP_PICK_UP_PET:
			print("DROP_PICK_UP_PET")
		NpcInteractions.SELL:
			print("SELL")
		NpcInteractions.BUY:
			print("BUY")
		NpcInteractions.RESURRECT_PET:
			print("RESURRECT_PET")
		NpcInteractions.TRADE_MOUNT:
			print("TRADE_MOUNT")
	


# func _on_npc_dialog_reponse_button_pressed(p_player_response_id: int):
# 	print("[Player] p_player_response_id ", p_player_response_id)
# 	dialog_actions.response(p_player_response_id)
# 	selected_npc_id = -1


# func _on_npc_dialog_cross_button_pressed() -> void:
# 	dialog_actions.leave()
# 	selected_npc_id = -1

#endregion
