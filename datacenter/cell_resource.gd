extends Resource
class_name CellResource

var id: int
var x: float
var y: float
var grid_x: int
var grid_y: int
var is_walkable: bool
var is_active: bool # Disable or not the entire cell. Don't know why it is used yet
var line_of_sight: bool
var movement: int
var cell_level: int # From 0 to 7 I think. Uused at MapResource init to determine world pos

var ground_slope: int # slope_id, used for example in grid_handler.SLOPE_POINTS
var ground_tile_id: int
var ground_tile_rot: int
var is_ground_tile_flip: bool

var object1_id: int
var object1_rot: int
var is_object1_flip: bool


var object2_id: int
var is_object2_interactive: bool
var is_object2_flip: bool
var object: int # Derived from object2_id and is_object2_interactive. See Compressor for more info


var object_external: String
var is_object_external_interactive: bool

var permanent_level: int
var is_targetable: bool
var raw_data: String # For debug purpose


func _init(p_id: int, p_raw_data: String) -> void:
	id  = p_id
	raw_data = p_raw_data
	
	var cell_dict: Dictionary = Compressor.uncompress_cell_data(p_raw_data, p_id)
	if cell_dict.is_empty():
		push_error("[CellResource] Failed to uncompress data for cell %d" % p_id)
		return
	
	is_walkable                          = cell_dict["is_walkable"]
	is_active                            = cell_dict["is_active"]
	line_of_sight                     = cell_dict["line_of_sight"]
	cell_level                      = cell_dict["cell_level"]
	movement                          = cell_dict["movement"]
	ground_slope                      = cell_dict["ground_slope"]
	object2_id                 			= cell_dict["object2_id"]
	is_object2_interactive         = cell_dict["is_object2_interactive"]
	object                            = cell_dict["object"]
	ground_tile_id                  = cell_dict["ground_tile_id"]
	ground_tile_rot                  = cell_dict["ground_tile_rot"]
	is_ground_tile_flip                 = cell_dict["is_ground_tile_flip"]
	object1_id                 = cell_dict["object1_id"]
	object1_rot                 = cell_dict["object1_rot"]
	is_object1_flip                = cell_dict["is_object1_flip"]
	is_object2_flip                = cell_dict["is_object2_flip"]
	object_external             = cell_dict["object_external"]
	is_object_external_interactive = cell_dict["is_object_external_interactive"]
	permanent_level                   = cell_dict["permanent_level"]
	is_targetable                     = cell_dict["is_targetable"]