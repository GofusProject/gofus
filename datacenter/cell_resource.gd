class_name CellResource
extends Resource



var raw_data: String # For debug purpose
var is_active: bool # `false` disable the entire cell. Don't know why it is used yet

# Position
var id: int
var world_position: Vector2
## For astar pathfinding
var diamond_grid_position: Vector2i
## For rendering
var staggered_grid_position: Vector2i
var cell_level: int # From 0 to 7 I think. Uused at MapResource init to determine world pos
var permanent_level: int

# Interaction
var is_walkable: bool
var line_of_sight: bool
var movement: int
var is_targetable: bool

# Ground
var ground_slope: int # slope_id, used for example in grid_handler.SLOPE_POINTS
var ground_tile_id: int
var ground_tile_rot: int
var is_ground_tile_flip: bool
var ground_texture: Texture2D = null
var ground_hframes: int = 0
var ground_offset: Vector2 = Vector2.ZERO

# Object1
var object1_id: int
var object1_rot: int
var is_object1_flip: bool
var object1_texture: Texture2D = null
var object1_offset: Vector2 = Vector2.ZERO

# Object1
var object2_id: int
var is_object2_interactive: bool
var is_object2_flip: bool
var object2_texture: Texture2D = null
var object2_offset: Vector2 = Vector2.ZERO
var object: int # Derived from object2_id and is_object2_interactive. See Compressor for more info

# Object external (don't know yet how it is used)
var object_external: String
var is_object_external_interactive: bool

# Action / Scripted cell
var action_id: ActionResource.ActionId
var event_id: int = -1
var action_arg_1: int = -1
var action_arg_2: int = -1
var conditions # to implement (see scripted cells table to see the format)



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


func initialize_ground_texture_and_offset(p_ground_texture: Texture2D, p_ground_offset: Vector2, p_ground_hframes: int) -> void:
	ground_texture = p_ground_texture
	ground_offset = p_ground_offset
	ground_hframes = p_ground_hframes


func initialize_object1_texture_and_offset(p_object1_texture: Texture2D, p_object1_offset: Vector2) -> void:
	object1_texture = p_object1_texture
	object1_offset = p_object1_offset


func initialize_object2_texture_and_offset(p_object2_texture: Texture2D, p_object2_offset: Vector2) -> void:
	object2_texture = p_object2_texture
	object2_offset = p_object2_offset


func initialize_action_properties(scripted_cell_data: Dictionary) -> void:
	action_id = int(scripted_cell_data["action_id"])
	event_id = int(scripted_cell_data["event_id"])
	event_id = int(scripted_cell_data["event_id"])

	var action_args_string: Array = scripted_cell_data["action_args"].split(",")
	action_arg_1 = int(action_args_string[0])
	action_arg_2 = int(action_args_string[1])
	
	conditions = scripted_cell_data["conditions"]

	print("Scripted cell id: ", id) 
