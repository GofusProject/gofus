class_name CellVisualResource
extends Resource

var id: int
var x: float
var y: float

var ground_slope: int
var ground_tile_id: int
var ground_tile_rot: int
var is_ground_tile_flip: bool
var ground_texture: Texture2D = null
var ground_hframes: int = 0
var ground_offset: Vector2 = Vector2.ZERO

var object1_id: int
var object1_rot: int
var is_object1_flip: bool
var object1_texture: Texture2D = null
var object1_offset: Vector2 = Vector2.ZERO

var object2_id: int
var is_object2_interactive: bool
var is_object2_flip: bool
var object2_texture: Texture2D = null
var object2_offset: Vector2 = Vector2.ZERO



func _init(cell_resource: CellResource) -> void:

	id = cell_resource.id
	x = cell_resource.x
	y = cell_resource.y

	ground_slope = cell_resource.ground_slope
	ground_tile_id = cell_resource.ground_tile_id
	ground_tile_rot = cell_resource.ground_tile_rot
	is_ground_tile_flip = cell_resource.is_ground_tile_flip

	object1_id = cell_resource.object1_id
	object1_rot = cell_resource.object1_rot
	is_object1_flip = cell_resource.is_object1_flip

	object2_id = cell_resource.object2_id
	is_object2_interactive = cell_resource.is_object2_interactive
	is_object2_flip = cell_resource.is_object2_flip


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
