extends Node


const NPC_TEMPLATE_CSV_PATH : String = "res://lang/npctemplate_fr_1130.csv"
const INTERACTIONS_CSV_PATH : String = "res://lang/npc_interactions_fr_1.csv"
const NPC_DIALOG_CSV_PATH : String = "res://lang/npc_dialog_fr_1.csv"
const NPC_DIALOG_PLAYER_RESPONSES_CSV_PATH : String = "res://lang/npc_dialog_player_responses_fr_1.csv"


var _npc_templates_cache: Dictionary = {}
var _npc_interactions_cache: Dictionary = {}
var _npc_dialogs_cache: Dictionary = {}
var _npc_dialog_player_responses_cache: Dictionary = {}


func _ready() -> void:
	_load_all_npc_templates()
	_load_all_npc_interactions()
	_load_all_npc_dialogs()
	_load_all_npc_dialog_player_responses()


## Load all npc_template data from CSV file
## Flow: CSV file → Dictionary of npc_template dictionaries
func _load_all_npc_templates() -> void:
	print("[GofusTranslater] Loading npc_templates from CSV: %s" % NPC_TEMPLATE_CSV_PATH)
	var file: FileAccess = FileAccess.open(NPC_TEMPLATE_CSV_PATH, FileAccess.READ)
	if not file:
		push_error("[GofusTranslater] Failed to open npc_templates CSV: " + NPC_TEMPLATE_CSV_PATH)
		return
	# Read header
	var header: PackedStringArray = file.get_csv_line()
	# Parse rows
	var count: int = 0
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 2:  # Skip empty/invalid rows, used to skip the last row get (empty)
			continue
		var npc_template_data: Dictionary = {
			"id": 		int(row[0]),
			"name": 	row[1],
		}
		_npc_templates_cache[npc_template_data.id] = npc_template_data
		count += 1
	file.close()
	print("[DofusTranslator] Loaded %d npc_templates from CSV" % count)


func _load_all_npc_interactions() -> void:
	print("[GofusTranslater] Loading npc_templates from CSV: %s" % INTERACTIONS_CSV_PATH)
	var file: FileAccess = FileAccess.open(INTERACTIONS_CSV_PATH, FileAccess.READ)
	if not file:
		push_error("[GofusTranslater] Failed to open npc_templates CSV: " + INTERACTIONS_CSV_PATH)
		return
	# Read header
	var header: PackedStringArray = file.get_csv_line()
	# Parse rows
	var count: int = 0
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 2:  # Skip empty/invalid rows, used to skip the last row get (empty)
			continue
		var npc_actions_data: Dictionary = {
			"id": 		int(row[0]),
			"name": 	row[1],
		}
		_npc_interactions_cache[npc_actions_data.id] = npc_actions_data
		count += 1
	file.close()
	print("[DofusTranslator] Loaded %d npc_actions from CSV" % count)


func _load_all_npc_dialogs() -> void:
	print("[GofusTranslater] Loading npc_templates from CSV: %s" % NPC_DIALOG_CSV_PATH)
	var file: FileAccess = FileAccess.open(NPC_DIALOG_CSV_PATH, FileAccess.READ)
	if not file:
		push_error("[GofusTranslater] Failed to open npc_templates CSV: " + NPC_DIALOG_CSV_PATH)
		return
	# Read header
	var header: PackedStringArray = file.get_csv_line()
	# Parse rows
	var count: int = 0
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 2:  # Skip empty/invalid rows, used to skip the last row get (empty)
			continue
		var npc_dialog_data: Dictionary = {
			"id": 		int(row[0]),
			"text": 	row[1],
		}
		_npc_dialogs_cache[npc_dialog_data.id] = npc_dialog_data
		count += 1
	file.close()
	print("[DofusTranslator] Loaded %d npc_actions from CSV" % count)


func _load_all_npc_dialog_player_responses() -> void:
	print("[GofusTranslater] Loading npc_templates from CSV: %s" % NPC_DIALOG_PLAYER_RESPONSES_CSV_PATH)
	var file: FileAccess = FileAccess.open(NPC_DIALOG_PLAYER_RESPONSES_CSV_PATH, FileAccess.READ)
	if not file:
		push_error("[GofusTranslater] Failed to open npc_templates CSV: " + NPC_DIALOG_PLAYER_RESPONSES_CSV_PATH)
		return
	# Read header
	var header: PackedStringArray = file.get_csv_line()
	# Parse rows
	var count: int = 0
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 2:  # Skip empty/invalid rows, used to skip the last row get (empty)
			continue
		var npc_dialog_player_response_data: Dictionary = {
			"id": 		int(row[0]),
			"text": 	row[1],
		}
		_npc_dialog_player_responses_cache[npc_dialog_player_response_data.id] = npc_dialog_player_response_data
		count += 1
	file.close()
	print("[DofusTranslator] Loaded %d npc_actions from CSV" % count)



## Retrieve npc_template data from cache using template_id as key
## Flow: template_id → raw npc_template data dictionary
func get_npc_template_lang(template_id: int) -> Dictionary:
	if not _npc_templates_cache.has(template_id):
		push_error("[GofusTranslater] NpcTemplate %d not found in cache" % template_id)
		return {}
	
	return _npc_templates_cache[template_id]


func get_npc_interaction_lang(npc_interaction_id: int) -> Dictionary:
	if not _npc_interactions_cache.has(npc_interaction_id):
		push_error("[GofusTranslater] NpcAction %d not found in cache" % npc_interaction_id)
		return {}
	
	return _npc_interactions_cache[npc_interaction_id]


func get_npc_dialog_lang(npc_dialog_id: int) -> Dictionary:
	if not _npc_dialogs_cache.has(npc_dialog_id):
		push_error("[GofusTranslater] NpcAction %d not found in cache" % npc_dialog_id)
		return {}
	
	return _npc_dialogs_cache[npc_dialog_id]


func get_npc_dialog_player_response_lang(npc_dialog_player_response_id: int) -> Dictionary:
	if not _npc_dialog_player_responses_cache.has(npc_dialog_player_response_id):
		push_error("[GofusTranslater] NpcAction %d not found in cache" % npc_dialog_player_response_id)
		return {}
	
	return _npc_dialog_player_responses_cache[npc_dialog_player_response_id]