extends Resource
class_name CellResource

var cell_id: int
var x: float
var y: float
var grid_x: int
var grid_y: int
var walkable: bool
var active: bool
var line_of_sight: bool
var ground_level: int
var movement: int
var ground_slope: int
var layer_object2_num: int
var layer_object2_interactive: bool
var object: int
var layer_ground_num: int
var layer_ground_rot: int
var layer_ground_flip: bool
var layer_object1_num: int
var layer_object1_rot: int
var layer_object1_flip: bool
var layer_object2_flip: bool
var layer_object_external: String
var layer_object_external_interactive: bool
var permanent_level: int
var is_targetable: bool
var raw_data: String

func _init(p_cell_id: int, p_raw_data: String) -> void:
	cell_id  = p_cell_id
	raw_data = p_raw_data
	
	var cell_dict: Dictionary = Compressor.uncompress_cell_data(p_raw_data, p_cell_id)
	if cell_dict.is_empty():
		push_error("[CellResource] Failed to uncompress data for cell %d" % p_cell_id)
		return
	
	walkable                          = cell_dict["walkable"]
	active                            = cell_dict["active"]
	line_of_sight                     = cell_dict["line_of_sight"]
	ground_level                      = cell_dict["ground_level"]
	movement                          = cell_dict["movement"]
	ground_slope                      = cell_dict["ground_slope"]
	layer_object2_num                 = cell_dict["layer_object2_num"]
	layer_object2_interactive         = cell_dict["layer_object2_interactive"]
	object                            = cell_dict["object"]
	layer_ground_num                  = cell_dict["layer_ground_num"]
	layer_ground_rot                  = cell_dict["layer_ground_rot"]
	layer_ground_flip                 = cell_dict["layer_ground_flip"]
	layer_object1_num                 = cell_dict["layer_object1_num"]
	layer_object1_rot                 = cell_dict["layer_object1_rot"]
	layer_object1_flip                = cell_dict["layer_object1_flip"]
	layer_object2_flip                = cell_dict["layer_object2_flip"]
	layer_object_external             = cell_dict["layer_object_external"]
	layer_object_external_interactive = cell_dict["layer_object_external_interactive"]
	permanent_level                   = cell_dict["permanent_level"]
	is_targetable                     = cell_dict["is_targetable"]