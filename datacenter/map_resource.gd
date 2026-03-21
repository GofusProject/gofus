extends Resource
class_name MapResource

var map_id: int
var date: String
var width: int
var height: int
var places: String
var key: String
var map_data: String
var npc_ids: Array[int]
var monsters: String
var capabilities: int
var map_pos: String
var numgroup: int
var min_size: int
var fix_size: int
var max_size: int
var forbidden: String
var sniffed: int
var music_id: int
var ambiance_id: int
var background_id: int
var out_door: int
var max_merchant: int
var cell_resources: Array[CellResource]
var cell_count: int

func _init(map_dict: Dictionary) -> void:
	map_id        = int(map_dict["id"])
	date          = str(map_dict["date"])
	width         = int(map_dict["width"])
	height        = int(map_dict["height"])
	places        = str(map_dict["places"])
	key           = str(map_dict["key"])
	map_data      = str(map_dict["map_data"])
	monsters      = str(map_dict["monsters"])
	capabilities  = int(map_dict["capabilities"])
	map_pos        = str(map_dict["map_pos"])
	numgroup      = int(map_dict["numgroup"])
	min_size      = int(map_dict["min_size"])
	fix_size      = int(map_dict["fix_size"])
	max_size      = int(map_dict["max_size"])
	forbidden     = str(map_dict["forbidden"])
	sniffed       = int(map_dict["sniffed"])
	music_id      = int(map_dict["music_id"])
	ambiance_id   = int(map_dict["ambiance_id"])
	background_id = int(map_dict["background_id"])
	out_door      = int(map_dict["out_door"])
	max_merchant  = int(map_dict["max_merchant"])
	
	# Parse npc_ids
	npc_ids = []
	if map_dict["npc_ids"] != "":
		for s in map_dict["npc_ids"].split(";"):
			npc_ids.append(int(s))
	
	# Build CellResources from map_data
	if map_data.length() % 10 != 0:
		push_error("[MapResource] map_data length must be divisible by 10, got: %d" % map_data.length())
		return
	
	cell_count = map_data.length() / 10
	cell_resources.resize(cell_count)
	
	for i in range(cell_count):
		var cell_data: String = map_data.substr(i * 10, 10)
		var cell_resource: CellResource = CellResource.new(i, cell_data)
		cell_resources[i] = cell_resource
