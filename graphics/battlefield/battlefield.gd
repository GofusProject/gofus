# battlefield.gd
extends Node2D



signal cell_clicked(cell_id: int)
signal cell_hovered(cell_id: int)
signal cell_unhovered(cell_id: int)

var map_handler: MapHandler
var character_sprite_handler: CharacterSpriteHandler
var over_head_handler: OverHeadHandler
var cell_interaction_handler: CellInteractionHandler
var spatial_handler: SpatialHandler

# Cell
const CELL_WIDTH: int = 106
const CELL_HALF_WIDTH: float = 53
const CELL_HEIGHT: int = 54  # Half-height for isometric
const CELL_HALF_HEIGHT: float = 27  # Half-height for isometric
const LEVEL_HEIGHT: int = 40  # Vertical offset per elevation level

# Slope
var slope_points_scaling: int = 2 # ! They are multiplied by 2 to match asset scaling 
const SLOPE_POINTS: Array = [ 
	[],
	[[-26.5,0],[0,-13.5],[26.5,0],[0,13.5]],
	[[-26.5,-20],[0,-13.5],[26.5,0],[0,13.5]],
	[[-26.5,0],[0,-33.5],[26.5,0],[0,13.5]],
	[[-26.5,-20],[0,-33.5],[26.5,0],[0,13.5]],
	[[-26.5,0],[0,-13.5],[26.5,-20],[0,13.5]],
	[[-26.5,-20],[0,-13.5],[26.5,-20],[0,13.5]],
	[[-26.5,0],[0,-33.5],[26.5,-20],[0,13.5]],
	[[-26.5,-20],[0,-33.5],[26.5,-20],[0,13.5]],
	[[-26.5,0],[0,-13.5],[26.5,0],[0,-6.5]],
	[[-26.5,-20],[0,-13.5],[26.5,0],[0,-6.5]],
	[[-26.5,0],[0,-33.5],[26.5,0],[0,-6.5]],
	[[-26.5,-20],[0,-33.5],[26.5,0],[0,-6.5]],
	[[-26.5,0],[0,-13.5],[26.5,-20],[0,-6.5]],
	[[-26.5,-20],[0,-13.5],[26.5,-20],[0,-6.5]],
	[[-26.5,0],[0,-33.5],[26.5,-20],[0,-6.5]]
]

# Layers
var background: Sprite2D
var ground_layer: Node2D
var object1_layer: Node2D
var object2_layer: Node2D
var interaction_layer: Node2D
var cell_ids_layer: Node2D
var character_sprites: Node2D
var player_character_layer: Node2D
var over_head_layer: Node2D
var grid_layer: Node2D
var cell_interaction_layer: Node2D
var debug_astar_layer: Node2D



const ANIMATED_CHARACTER_SPRITE_2D_SCENE: PackedScene = preload("res://graphics/battlefield/scenes/AnimatedCharacterSprite2D.tscn")
const TEXT_OVER_HEAD_SCENE: PackedScene = preload("res://graphics/battlefield/scenes/TextOverHead.tscn")




## Initializes dependencies and event listening
func _ready() -> void:

	map_handler = MapHandler.new()
	character_sprite_handler = CharacterSpriteHandler.new()
	over_head_handler = OverHeadHandler.new()
	cell_interaction_handler = CellInteractionHandler.new()
	spatial_handler = SpatialHandler.new()

	background = get_node_or_null("Background")
	ground_layer = get_node_or_null("GroundLayer")
	object1_layer = get_node_or_null("Object1Layer")
	object2_layer = get_node_or_null("Object2Layer")
	interaction_layer = get_node_or_null("InteractionLayer")
	cell_ids_layer = get_node_or_null("CellIDSLayer")
	character_sprites = get_node_or_null("CharacterSprites")
	player_character_layer = get_node_or_null("PlayerCharacterLayer")
	over_head_layer = get_node_or_null("OverHeadLayer")
	grid_layer = get_node_or_null("GridLayer")
	cell_interaction_layer = get_node_or_null("CellInteractionLayer")
	debug_astar_layer = get_node_or_null("DebugAStarLayer")

	background.centered = false



func build_map(p_background_id, p_map_staggered_width: int, p_cell_resources: Array[CellResource], p_grid_start: Vector2i, p_grid_size: Vector2i) -> void:

	map_handler.render_map(p_background_id, p_map_staggered_width, p_cell_resources)
	spatial_handler.setup_astar_2d_grid(p_map_staggered_width, p_cell_resources)

	for cell_resource in p_cell_resources:
		cell_interaction_handler.create_cell_area(
			cell_resource.world_position,
			cell_resource.ground_slope,
			cell_resource.movement,
			cell_resource.id
		)



#region OverHeadHandler

func show_character_over_head(p_character_id: int, p_name: String) -> void:
	var animated_character_sprite_2d: AnimatedCharacterSprite2D = character_sprite_handler.get_animated_character_sprite_2d_by_character_id(p_character_id)
	over_head_handler.create_over_head(animated_character_sprite_2d, p_name)


func hide_character_over_head() -> void:
	over_head_handler.destroy_all_over_head()


#endregion


func clear() -> void:
	hide_character_over_head()
	map_handler.clear()
	character_sprite_handler.clear()
	cell_interaction_handler.clear()
	spatial_handler.clear()
