# Database.gd
# AutoLoad singleton
# Handles data persistence and provides quick access to data

extends Node


const MAPS_CSV_PATH : String = "res://database/maps_database.csv"
const NPC_TEMPLATE_CSV_PATH: String = "res://database/npc_template_database.csv"
const NPCS_CSV_PATH: String = "res://database/npcs_database.csv"
const DIALOG_QUESTIONS_CSV_PATH: String = "res://database/dialog_questions_database.csv"
const DIALOG_RESPONSE_ACTIONS_CSV_PATH: String = "res://database/dialog_response_actions_database.csv"


# I tried to use an array instead, but very little gains in the end
var _npc_template_cache: Dictionary[int, Dictionary] = {}
var _npcs_cache: Dictionary[int, Dictionary] = {}
var _maps_cache: Dictionary[int, Dictionary] = {} 
var _npc_dialogs_cache: Dictionary[int, Dictionary] = {} 
var _npc_dialogs_player_responses_cache: Dictionary[int, Dictionary] = {} 


func _ready() -> void:
	print("[Database] Initializing...")

	var build_start_time : int = Time.get_ticks_usec()
	var mem_before := Performance.get_monitor(Performance.MEMORY_STATIC)

	_load_all_maps()
	_load_all_npc_templates()
	_load_all_npcs()
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


func _load_all_maps() -> void:
	print("[Database] Loading maps from CSV: %s" % MAPS_CSV_PATH)
	
	var file: FileAccess = FileAccess.open(MAPS_CSV_PATH, FileAccess.READ)
	if not file:
		push_error("[Database] Failed to open maps CSV: " + MAPS_CSV_PATH)
		return
	
	var header: PackedStringArray = file.get_csv_line()
	
	var count: int = 0
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 7:
			continue
		
		var map_dict: Dictionary = {
			"map_id":       row[0],
			"date":         row[1],
			"width":        row[2],
			"height":       row[3],
			"places":       row[4],
			"key":          row[5],
			"map_data":     row[6],
			"npc_ids":      row[7],
			"monsters":     row[8],
			"capabilities": row[9],
			"mappos":       row[10],
			"numgroup":     row[11],
			"min_size":     row[12],
			"fix_size":     row[13],
			"max_size":     row[14],
			"forbidden":    row[15],
			"sniffed":      row[16],
			"music_id":     row[17],
			"ambiance_id":  row[18],
			"bg_id":        row[19],
			"out_door":     row[20],
			"max_merchant": row[21],
		}
		
		_maps_cache[int(row[0])] = map_dict
		count += 1
	
	file.close()
	print("[Database] Loaded %d maps from CSV" % count)


## Load all npc_template data from CSV file
## Flow: CSV file → Dictionary of npc_template dictionaries
func _load_all_npc_templates() -> void:
	print("[Database] Loading npc_templates from CSV: %s" % NPC_TEMPLATE_CSV_PATH)
	var file: FileAccess = FileAccess.open(NPC_TEMPLATE_CSV_PATH, FileAccess.READ)
	if not file:
		push_error("[Database] Failed to open npc_templates CSV: " + NPC_TEMPLATE_CSV_PATH)
		return
	# Read header
	var header: PackedStringArray = file.get_csv_line()
	# Parse rows
	var count: int = 0
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 18:  # Skip empty/invalid rows, used to skip the last row get (empty)
			continue
		var npc_template_data: Dictionary = {
			"id":            	row[0],
			"bonusValue":    	row[1],
			"gfxID":         	row[2],
			"scaleX":        	row[3],
			"scaleY":        	row[4],
			"sex":           	row[5],
			"color1":        	row[6],
			"color2":        	row[7],
			"color3":        	row[8],
			"accessories":   	row[9],
			"extraClip":     	row[10],
			"customArtwork": 	row[11],
			"interaction_ids": 	row[12],
			"initQuestion":  	row[13],
			"ventes":        	row[14],
			"quests":        	row[15],
			"exchanges":     	row[16],
			"path":          	row[17],
			"informations":  	row[18]
		}
		_npc_template_cache[int(npc_template_data.id)] = npc_template_data
		count += 1
	file.close()
	print("[Database] Loaded %d npc_templates from CSV" % count)


## Load all npc data from CSV file
## Flow: CSV file → Dictionary of npc dictionaries
func _load_all_npcs() -> void:
	print("[Database] Loading npcs from CSV: %s" % NPCS_CSV_PATH)
	var file: FileAccess = FileAccess.open(NPCS_CSV_PATH, FileAccess.READ)
	if not file:
		push_error("[Database] Failed to open npcs CSV: " + NPCS_CSV_PATH)
		return
	# Read header
	var header: PackedStringArray = file.get_csv_line()
	# Parse rows
	var count: int = 0
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 5:  # Skip empty/invalid rows, used to skip the last row get (empty)
			continue
		var npc_data: Dictionary = {
			"id":				row[0],
			"mapid":       		row[1],
			"npcTemplateId":	row[2],
			"cellid":      		row[3],
			"orientation": 		row[4],
			"isMovable":   		row[5]
		}
		_npcs_cache[int(npc_data.id)] = npc_data
		count += 1
	file.close()
	print("[Database] Loaded %d npcs from CSV" % count)


## Retrieve map dictionary from cache using map_id as key
## Flow: map_id → Dictionary
func get_map_dict(map_id: int) -> Dictionary:
	if not _maps_cache.has(map_id):
		push_error("[Database] Map %d not found in cache" % map_id)
		return {}
	return _maps_cache[map_id]


## Retrieve npc_template data from cache using template_id as key
## Flow: template_id → raw npc_template data dictionary
func get_npc_template_dict(template_id: int) -> Dictionary:
	if not _npc_template_cache.has(template_id):
		push_error("[Database] NpcTemplate %d not found in cache" % template_id)
		return {}
	
	return _npc_template_cache[template_id]


## Retrieve npcs data from cache using map_id as key
## Flow: map_id → array of npc data dictionaries
func get_npc_dict(p_npc_id: int) -> Dictionary:
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
