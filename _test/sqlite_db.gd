extends Node


var db : SQLite = null
var db_name : String = "res://database/gofus_database.db"

const verbosity_level : int = SQLite.VERBOSE

func _ready() -> void:
	# New database connection
	db = SQLite.new()
	db.path = db_name
	db.open_db()

	print(get_dialog_response_actions_by_id(10354))

func get_dialog_response_actions_by_id(p_id: int) -> Dictionary:

	
	# Query
	var query = "SELECT * FROM maps WHERE id = '%s'" % p_id # Use parameterized query to avoid SQL injection
	db.query(query)

	if db.query_result.size() > 0:
		return db.query_result[0]  # Return first result as a dictionary
	else:
		print("Dialog reponse action not found in the DB")
		return {}  # Return an empty dictionary if not found
