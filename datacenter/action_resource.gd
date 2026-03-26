class_name ActionResource
extends Resource


## Les action_id sont liés à Action.java
enum ActionId {
	START = 2000,
	CONTINUE_DIALOG = 1,
	RESPOND_TO_NPC = 1999,
	LEAVE = 2001,
	MOVE_CHARACTER_ON_MAP = 2002
}


var action_id: int
var param_1: int     # spell_id, item_id...
var param_2: int    # quantity...
var condition # ActionCondition, to implement



func _init(p_action_id , p_param_1: int = -1, p_param_2: int = -1) -> void:
	action_id = p_action_id
	param_1 = p_param_1
	param_2 = p_param_2