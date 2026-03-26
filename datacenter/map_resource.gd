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
var active_cells: int = 0

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
	

	var col: int = -1
	var row: int = 0
	var x_offset: float = 0
	var max_col: int = width - 1

	for i in range(cell_count):
		var cell_data: String = map_data.substr(i * 10, 10)
		var cell_resource: CellResource = CellResource.new(i, cell_data)

		# Grid positioning (isometric logic)
		if col == max_col:
			col = 0
			row += 1
  
			if x_offset == 0:
				x_offset = Battlefield.CELL_HALF_WIDTH
				max_col -= 1
			else:
				x_offset = 0
				max_col += 1
		else:
			col += 1

		# Grid position
		cell_resource.grid_x = col
		cell_resource.grid_y = row
  
		# World positioning
		var cell_world_x: float = col * Battlefield.CELL_WIDTH + x_offset
		var cell_world_y: float = row * Battlefield.CELL_HALF_HEIGHT \
			- Battlefield.LEVEL_HEIGHT * (cell_resource.cell_level - 7)
  
		var cell_position: Vector2 = Vector2(cell_world_x, cell_world_y)
		cell_resource.x = cell_position.x
		cell_resource.y = cell_position.y

		if not cell_resource.is_active:
			print("[MapResource] Cell %s is not active" % cell_resource.id)
			continue
		
		active_cells += 1

		cell_resources[i] = cell_resource


	

