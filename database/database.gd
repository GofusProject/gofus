# Database.gd
# AutoLoad singleton
# Handles data persistence via SQLite and provides quick access to data
class_name Database
extends Node

const DB_PATH: String = "res://database/gofus_database.db"
const VERBOSITY_LEVEL: int = SQLite.NORMAL

var db: SQLite = null

# ─────────────────────────────────────────────
#  Lifecycle
# ─────────────────────────────────────────────

func _ready() -> void:
	print("[Database] Initializing...")
	db = SQLite.new()
	db.path = DB_PATH
	db.verbosity_level = VERBOSITY_LEVEL
	if not db.open_db():
		push_error("[Database] Failed to open database at: " + DB_PATH)
		return
	print("[Database] Ready — connected to: %s" % DB_PATH)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and db:
		db.close_db()
		print("[Database] Connection closed.")

# ─────────────────────────────────────────────
#  Internal helpers
# ─────────────────────────────────────────────

## Generic single-row fetch. Returns {} if nothing found or DB is unavailable.
func _fetch_one(table: String, id: int) -> Dictionary:
	if not db:
		push_error("[Database] DB not initialised.")
		return {}
	db.query_with_bindings(
		"SELECT * FROM %s WHERE id = ?;" % table,
		[id]
	)
	if db.query_result.is_empty():
		push_error("[Database] No row found in '%s' for id=%d" % [table, id])
		return {}
	return db.query_result[0]


## Generic multi-row fetch. Returns [] if nothing found or DB is unavailable.
func _fetch_all(table: String) -> Array:
	if not db:
		push_error("[Database] DB not initialised.")
		return []
	db.query("SELECT * FROM %s;" % table)
	return db.query_result


## Generic filtered fetch. Returns [] if nothing found or DB is unavailable.
func _fetch_where(table: String, column: String, value: Variant) -> Array:
	if not db:
		push_error("[Database] DB not initialised.")
		return []
	db.query_with_bindings(
		"SELECT * FROM %s WHERE %s = ?;" % [table, column],
		[value]
	)
	return db.query_result

# ─────────────────────────────────────────────
#  Public getters
# ─────────────────────────────────────────────

func get_map_data(p_id: int) -> Dictionary:
	return _fetch_one("maps", p_id)


func get_npc_template_data(p_id: int) -> Dictionary:
	return _fetch_one("npc_templates", p_id)


func get_npc_data(p_id: int) -> Dictionary:
	return _fetch_one("npcs", p_id)


func get_dialog_question_data(p_id: int) -> Dictionary:
	return _fetch_one("dialog_questions", p_id)


func get_dialog_response_action_data(p_id: int) -> Dictionary:
	return _fetch_one("dialog_response_actions", p_id)


func get_player_data(p_id: int) -> Dictionary:
	return _fetch_one("players", p_id)


func get_scripted_cell_data(p_map_id: int) -> Array[Dictionary]:
	return _fetch_where("scripted_cells", "map_id", p_map_id)



# ## Returns all dialog questions for a given dialog.
# func get_dialog_questions_for_dialog(p_dialog_id: int) -> Array:
# 	return _fetch_where("dialog_questions", "dialog_id", p_dialog_id)


# ## Returns all response actions for a given question.
# func get_response_actions_for_question(p_question_id: int) -> Array:
# 	return _fetch_where("dialog_response_actions", "question_id", p_question_id)