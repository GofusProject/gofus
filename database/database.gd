# Database.gd
# AutoLoad singleton
# Handles data persistence and provides quick access to data

extends Node


const MAPS_CSV_PATH : String = "res://database/maps_database.csv"
const NPC_TEMPLATE_CSV_PATH: String = "res://database/npc_template_database.csv"
const NPCS_CSV_PATH: String = "res://database/npcs_database.csv"
const DIALOG_QUESTIONS_CSV_PATH: String = "res://database/dialog_questions_database.csv"
const DIALOG_RESPONSE_ACTIONS_CSV_PATH: String = "res://database/dialog_response_actions_database.csv"
const PLAYER_CSV_PATH: String = "res://database/player_database.csv"


# I tried to use arrays instead, but very little gains in the end
var _npc_template_cache: Dictionary[int, Dictionary] = {}
var _npcs_cache: Dictionary[int, Dictionary] = {}
var _maps_cache: Dictionary[int, Dictionary] = {} 
var _dialog_questions_cache: Dictionary[int, Dictionary] = {} 
var _dialog_response_actions_cache: Dictionary[int, Dictionary] = {} 
var _player_cache: Dictionary[int, Dictionary] = {} 



func _ready() -> void:
	print("[Database] Initializing...")

	var build_start_time : int = Time.get_ticks_usec()
	var mem_before := Performance.get_monitor(Performance.MEMORY_STATIC)

	_load_csv_into_cache(MAPS_CSV_PATH, _maps_cache)
	_load_csv_into_cache(NPC_TEMPLATE_CSV_PATH, _npc_template_cache)
	_load_csv_into_cache(NPCS_CSV_PATH, _npcs_cache)
	_load_csv_into_cache(DIALOG_QUESTIONS_CSV_PATH, _dialog_questions_cache)
	_load_csv_into_cache(DIALOG_RESPONSE_ACTIONS_CSV_PATH, _dialog_response_actions_cache)
	_load_csv_into_cache(PLAYER_CSV_PATH, _player_cache)

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


func _get_from_cache(cache: Dictionary, id: int, label: String) -> Dictionary:
	if not cache.has(id):
		push_error("[Database] %s %d not found in cache" % [label, id])
		return {}
	return cache[id]


func get_map_data(p_map_id: int) -> Dictionary:
	return _get_from_cache(_maps_cache, p_map_id, "Map")


func get_npc_template_data(p_template_id: int) -> Dictionary:
	return _get_from_cache(_npc_template_cache, p_template_id, "NpcTemplate")


func get_npc_data(p_npc_id: int) -> Dictionary:
	return _get_from_cache(_npcs_cache, p_npc_id, "Npc")


func get_dialog_question_data(p_npc_dialog_id: int) -> Dictionary:
	return _get_from_cache(_dialog_questions_cache, p_npc_dialog_id, "NpcDialog")


func get_dialog_response_action_data(p_npc_dialog_player_response_id: int) -> Dictionary:
	return _get_from_cache(_dialog_response_actions_cache, p_npc_dialog_player_response_id, "DialogResponseActions")


func get_player_data(p_player_id: int) -> Dictionary:
	return _get_from_cache(_player_cache, p_player_id, "Player")
