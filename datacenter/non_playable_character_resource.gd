class_name NonPlayableCharacterResource
extends CharacterResource

var npc_id: int
var npc_template_id: int
var bonusValue
var sex
var extraClip
var custom_artwork: int
var interaction_ids: Array[int]
var init_dialog_map_to_id: Dictionary[int, int]
var ventes
var quests
var exchanges
var path
var informations


func _init(p_npc_data: Dictionary, p_npc_template_data: Dictionary,	p_npc_template_lang: Dictionary) -> void:

	super(
		p_npc_template_lang["name"],
		int(p_npc_data["cellid"]),
		int(p_npc_data["mapid"]),
		int(p_npc_template_data["gfx_id"]),
		int(p_npc_data["orientation"]),
		int(p_npc_template_data["color1"]),
		int(p_npc_template_data["color2"]),
		int(p_npc_template_data["color3"])
	)

	npc_id           = int(p_npc_data["id"])
	npc_template_id  = int(p_npc_template_data["id"])
	bonusValue       = p_npc_template_data["bonus_value"]
	sex              = p_npc_template_data["sex"]
	extraClip        = p_npc_template_data["extra_clip"]
	custom_artwork   = int(p_npc_template_data["custom_artwork"])
	ventes           = p_npc_template_data["ventes"]
	quests           = p_npc_template_data["quests"]
	exchanges        = p_npc_template_data["exchanges"]
	path             = p_npc_template_data["path"]
	informations     = p_npc_template_data["informations"]


	# Dialog ids
	if p_npc_template_data["init_question"] == "":
		init_dialog_map_to_id = {}
	else:
		var dialog_parts = p_npc_template_data["init_question"].split("|")
		if dialog_parts.size() == 1:
			# Single dialog format, ex: 3154 
			init_dialog_map_to_id = { -1: int(dialog_parts[0])} # -1 is used to indicate that there is no map condition
		else:
			# Multiple questions format: "mapId1,questionId1|mapId2,questionId2" to Dictionary[int, int]
			# Ex: 9538,3204|9876,3201|-1,3207|9557,3208|9877,3210|9881,3213
			for dialog in dialog_parts:
				var map_dialog = dialog.split(",")
				init_dialog_map_to_id[map_dialog[0].to_int()] = map_dialog[1].to_int()

	# Interactions ids
	interaction_ids = []
	if p_npc_template_data["interaction_ids"] != "":
		for s in p_npc_template_data["interaction_ids"].split(","):
			interaction_ids.append(int(s))
