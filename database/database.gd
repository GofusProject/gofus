# Database.gd
# AutoLoad singleton
# Handles data persistence and provides quick access to data

extends Node


const MAPS_CSV_PATH : String = "res://database/maps_database.csv"
const NPC_TEMPLATE_CSV_PATH: String = "res://database/npc_template_database.csv"
const NPCS_CSV_PATH: String = "res://database/npcs_database.csv"
const DIALOG_QUESTIONS_CSV_PATH: String = "res://database/dialog_questions_database.csv"
const DIALOG_RESPONSE_ACTIONS_CSV_PATH: String = "res://database/dialog_response_actions_database.csv"


# I tried to use arrays instead, but very little gains in the end
var _npc_template_cache: Dictionary[int, Dictionary] = {}
var _npcs_cache: Dictionary[int, Dictionary] = {}
var _maps_cache: Dictionary[int, Dictionary] = {} 
var _npc_dialogs_cache: Dictionary[int, Dictionary] = {} 
var _npc_dialogs_player_responses_cache: Dictionary[int, Dictionary] = {} 


func _ready() -> void:
	print("[Database] Initializing...")

	var build_start_time : int = Time.get_ticks_usec()
	var mem_before := Performance.get_monitor(Performance.MEMORY_STATIC)

	_load_csv_into_cache(MAPS_CSV_PATH, _maps_cache)
	_load_csv_into_cache(NPC_TEMPLATE_CSV_PATH, _npc_template_cache)
	_load_csv_into_cache(NPCS_CSV_PATH, _npcs_cache)
	_load_csv_into_cache(DIALOG_QUESTIONS_CSV_PATH, _npc_dialogs_cache)
	_load_csv_into_cache(DIALOG_RESPONSE_ACTIONS_CSV_PATH, _npc_dialogs_player_responses_cache)

	var build_end_time : int = Time.get_ticks_usec()
	var build_time_sec : float = (build_end_time - build_start_time) / 1_000_000.0
	print("[Database] Ready (took %.2f sec)" % build_time_sec)

	var mem_after := Performance.get_monitor(Performance.MEMORY_STATIC)
	var mem_used := mem_after - mem_before
	var mb = mem_used / (1024.0 * 1024.0)
	print("[Database] Approximate cache memory size: %.3f MB" % mb)


func _load_csv_into_cache(csv_path: String,	cache: Dictionary[int, Dictionary]) -> void:
	print("[Database] Loading from CSV: %s" % csv_path)
	var file: FileAccess = FileAccess.open(csv_path, FileAccess.READ)
	if not file:
		push_error("[Database] Failed to open CSV: " + csv_path)
		return

	var column_names: PackedStringArray = file.get_csv_line()
	var expected_columns: int = column_names.size()

	var count: int = 0
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < expected_columns:
			print("[Database] Row with id " + row[0] + " skipped.")
			continue
		var entry: Dictionary = {}
		for i in column_names.size():
			entry[column_names[i]] = row[i]
		cache[int(row[0])] = entry
		count += 1

	file.close()
	print("[Database] Loaded %d entries from CSV" % count)


func get_map_data(map_id: int) -> Dictionary:
	if not _maps_cache.has(map_id):
		push_error("[Database] Map %d not found in cache" % map_id)
		return {}
	return _maps_cache[map_id]


func get_npc_template_data(template_id: int) -> Dictionary:
	if not _npc_template_cache.has(template_id):
		push_error("[Database] NpcTemplate %d not found in cache" % template_id)
		return {}
	
	return _npc_template_cache[template_id]


func get_npc_data(p_npc_id: int) -> Dictionary:
	if not _npcs_cache.has(p_npc_id):
		push_error("[Database] Npc %d not found in cache" % p_npc_id)
		return {}
	
	return _npcs_cache[p_npc_id]


func get_npc_dialog_data(p_npc_dialog_id: int) -> Dictionary:
	if not _npc_dialogs_cache.has(p_npc_dialog_id):
		push_error("[Database] Npc dialog %d not found in cache" % p_npc_dialog_id)
		return {}
	
	return _npc_dialogs_cache[p_npc_dialog_id]


func get_npc_dialog_player_response_data(p_npc_dialog_player_response_id: int) -> Dictionary:
	if not _npc_dialogs_player_responses_cache.has(p_npc_dialog_player_response_id):
		push_error("[Database] Player response %d not found in cache" % p_npc_dialog_player_response_id)
		return {}
	
	return _npc_dialogs_player_responses_cache[p_npc_dialog_player_response_id]
