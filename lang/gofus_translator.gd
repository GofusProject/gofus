class_name GofusTranslator
extends Node



var is_debug_mode: bool = false

const NPC_TEMPLATE_CSV_PATH:           String = "res://lang/npc_template_lang.csv"
const NPC_INTERACTIONS_CSV_PATH:       String = "res://lang/npc_interactions_lang.csv"
const DIALOG_QUESTIONS_CSV_PATH:       String = "res://lang/dialog_questions_lang.csv"
const DIALOG_RESPONSES_CSV_PATH:       String = "res://lang/dialog_responses_lang.csv"
const SUPER_AREA_CSV_PATH:             String = "res://lang/super_area_lang.csv"
const AREA_CSV_PATH:                   String = "res://lang/area_lang.csv"
const SUBAREA_CSV_PATH:                String = "res://lang/subarea_lang.csv"


# For now langage switching is not implemented (only fr is loaded)
var _npc_templates_cache:              Dictionary[int, String] = {}
var _npc_interactions_cache:           Dictionary[int, String] = {}
var _dialog_questions_cache:           Dictionary[int, String] = {}
var _dialog_responses_cache:           Dictionary[int, String] = {}
var _super_area_cache:                Dictionary[int, String] = {}
var _area_cache:                      Dictionary[int, String] = {}
var _subarea_cache:                   Dictionary[int, String] = {}



func _ready() -> void:
	if is_debug_mode: print("[Translator] Initializing...")
	var build_start_time: int = Time.get_ticks_usec()
	var mem_before : float = Performance.get_monitor(Performance.MEMORY_STATIC)

	_load_csv_into_cache(NPC_TEMPLATE_CSV_PATH,     _npc_templates_cache)
	_load_csv_into_cache(NPC_INTERACTIONS_CSV_PATH, _npc_interactions_cache)
	_load_csv_into_cache(DIALOG_QUESTIONS_CSV_PATH, _dialog_questions_cache)
	_load_csv_into_cache(DIALOG_RESPONSES_CSV_PATH, _dialog_responses_cache)
	_load_csv_into_cache(SUPER_AREA_CSV_PATH, _super_area_cache)
	_load_csv_into_cache(AREA_CSV_PATH, _area_cache)
	_load_csv_into_cache(SUBAREA_CSV_PATH, _subarea_cache)

	var build_end_time: int = Time.get_ticks_usec()
	var build_time_sec: float = (build_end_time - build_start_time) / 1_000_000.0
	if is_debug_mode: print("[Translator] Ready (took %.2f sec)" % build_time_sec)
	var mem_after : float = Performance.get_monitor(Performance.MEMORY_STATIC)
	var mem_used : float = mem_after - mem_before
	var mb: float = mem_used / (1024.0 * 1024.0)
	if is_debug_mode: print("[Translator] Approximate cache memory size: %.3f MB" % mb)


func _load_csv_into_cache(csv_path: String, cache: Dictionary[int, String]) -> void:
	if is_debug_mode: print("[Translator] Loading from CSV: %s" % csv_path)
	var file: FileAccess = FileAccess.open(csv_path, FileAccess.READ)
	if not file:
		push_error("[Translator] Failed to open CSV: " + csv_path)
		return

	var count: int = 0

	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row[0] == "": # csv try to read the row after the last row
			continue
		var text: String = row[1] # fr text
		cache[int(row[0])] = text
		count += 1

	file.close()
	if is_debug_mode: print("[Translator] Loaded %d entries from CSV" % count)


func _get_from_cache(cache: Dictionary, id: int, label: String) -> String:
	if not cache.has(id):
		push_error("[Translator] %s %d not found in cache" % [label, id])
		return ""
	return cache[id]


func get_npc_template_name(p_template_id: int) -> String:
	return _get_from_cache(_npc_templates_cache, p_template_id, "NpcTemplate")


func get_npc_interaction_text(p_npc_interaction_id: int) -> String:
	return _get_from_cache(_npc_interactions_cache, p_npc_interaction_id, "NpcInteraction")


func get_dialog_question_text(p_dialog_question_id: int) -> String:
	return _get_from_cache(_dialog_questions_cache, p_dialog_question_id, "DialogQuestion")


func get_dialog_response_text(p_dialog_response_id: int) -> String:
	return _get_from_cache(_dialog_responses_cache, p_dialog_response_id, "DialogResponse")


func get_super_area_name(p_super_area_id: int) -> String:
	return _get_from_cache(_super_area_cache, p_super_area_id, "SuperArea")


func get_area_name(p_area_id: int) -> String:
	return _get_from_cache(_area_cache, p_area_id, "Area")


func get_subarea_name(p_subarea_id: int) -> String:
	return _get_from_cache(_subarea_cache, p_subarea_id, "SubArea")