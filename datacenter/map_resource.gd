extends Resource
class_name MapResource

var map_id: int
var date: String
## For rendering
var staggered_width: int
var staggered_height: int
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

## For astar pathfinding
var diamond_grid_start: Vector2i = Vector2i.ZERO
var diamond_grid_size: Vector2i = Vector2i.ZERO
var diamond_end_grid_y: int = 0


func _init(map_dict: Dictionary) -> void:
	map_id        = int(map_dict["id"])
	date          = str(map_dict["date"])
	staggered_width         = int(map_dict["width"])
	staggered_height        = int(map_dict["height"])
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
	
	@warning_ignore("integer_division")
	cell_count = map_data.length() / 10 
	cell_resources.resize(cell_count)
	

	var col: int = -1
	var row: int = 0
	var x_offset: float = 0
	var max_col: int = staggered_width - 1

	for i in range(cell_count):
		var cell_data: String = map_data.substr(i * 10, 10)
		var cell_resource: CellResource = CellResource.new(i, cell_data)

		# World grid positioning (isometric logic)
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


		# Map grid positioning
		cell_resource.staggered_grid_y = row - col
		@warning_ignore("integer_division")
		cell_resource.staggered_grid_x = (cell_resource.id - (staggered_width - 1) * cell_resource.staggered_grid_y) / staggered_width

		cell_resource.diamond_grid_y = (staggered_width * row) - cell_resource.id
		cell_resource.diamond_grid_x = cell_resource.id - (staggered_width - 1) * row


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


		# Calculate map diamond size, start point and end point
		if cell_resource.diamond_grid_y < diamond_grid_start.y: # diamond_grid_start.y
			diamond_grid_start.y = cell_resource.diamond_grid_y
		if cell_resource.diamond_grid_y > diamond_end_grid_y: # diamond_end_grid_y
			diamond_end_grid_y = cell_resource.diamond_grid_y	

		# Calculate map diamond size
		if cell_resource.diamond_grid_x > diamond_grid_size.x: # diamond_grid_size.x
			diamond_grid_size.x = cell_resource.diamond_grid_x

	
	diamond_grid_size.y = diamond_end_grid_y - diamond_grid_start.y
	
	print("Diamond map size: %s" % str(diamond_grid_size))
