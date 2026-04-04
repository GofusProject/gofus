## Orchestrates map loading by coordinating database, Compressor, and datacenter to build MapResource
class_name MapManager
extends Node



signal scripted_cell_triggered(action_resource: ActionResource)

var is_debug_mode: bool = true

# Counters for statistics
var ground_tiles: int = 0
var object1_tiles: int = 0
var object2_tiles: int = 0

# Modules
var database: Database
var datacenter: Datacenter
var gofus_translator: GofusTranslator
var asset_loader: AssetLoader
var battlefield: Battlefield
var ui: UI



func initialize(p_database: Database,
	p_datacenter: Datacenter,
	p_gofus_translator: GofusTranslator,
	p_asset_loader: AssetLoader,
	p_battlefield: Battlefield,
	p_ui: UI) -> void:

	database = p_database
	datacenter = p_datacenter
	gofus_translator = p_gofus_translator
	asset_loader = p_asset_loader
	battlefield = p_battlefield
	ui = p_ui



func setup_signals(p_characters_manager: CharactersManager) -> void:
	battlefield.cell_clicked.connect(_on_cell_clicked)
	battlefield.cell_hovered.connect(_on_cell_hovered)
	battlefield.cell_unhovered.connect(_on_cell_unhovered)

	p_characters_manager.character_world_path_point_reached.connect(_on_character_manager_character_world_path_point_reached)


## Orchestrate map creation process
## Return true if map successfully created, false if not
func create_map(map_id: int) -> bool:
	PerformanceTracker.start_timer("MapManager", "Map creation")
	
	# 1. Database
	var map_dict: Dictionary = database.get_map_data(map_id)
	if map_dict.is_empty():
		push_error("[MapManager] No map dictionary for map %d" % map_id)
		return false
	
	# 2. Datacenter and MapResource
	var map_resource: MapResource = MapResource.new(map_dict)
	if map_resource.cell_count == 0:
		push_error("[MapManager] MapResource initialization failed for map %d: cell count = 0" % map_id)
		return false

	if map_resource.active_cells == 0:
		push_error("[MapManager] MapResource initialization failed for map %d: no active cells" % map_id)
		return false

	
	print("[MapManager] Current map resource : width=%d, height=%d, bgID=%d, cell count=%d" % [map_resource.size.x, map_resource.size.y, map_resource.background_id, map_resource.cell_count])
	
	datacenter.set_current_map_resource(map_resource)

	# 3. AssetLoader, CellResource sprite init and Background texture init

	if map_resource.background_id != 0:
		map_resource.background_texture = asset_loader.get_background_texture(map_resource.background_id)

	for cell_resource in map_resource.cell_resources:

		if cell_resource.ground_tile_id != 0:
			var ground_texture = asset_loader.get_ground_tile_texture(cell_resource.ground_tile_id)
			var ground_sprite_metadata: Dictionary = asset_loader.get_ground_sprite_metadata(cell_resource.ground_tile_id)
			var ground_offset = Vector2( # TODO: Convert in SpriteMetadataResource
				ground_sprite_metadata["horizontal"],
				ground_sprite_metadata["vertical"]
			)
			var ground_hframes = ground_sprite_metadata["frame_count"]
			cell_resource.initialize_ground_texture_and_offset(ground_texture, ground_offset, ground_hframes)
			ground_tiles += 1

		if cell_resource.object1_id != 0:
			var object1_sprite_texture = asset_loader.get_object_sprite_texture(cell_resource.object1_id)
			var object1_bounds_metadata: Dictionary = asset_loader.get_object_sprite_metadata(cell_resource.object1_id)
			var object1_offset = Vector2( # TODO: Convert in SpriteMetadataResource
				object1_bounds_metadata["horizontal"],
				object1_bounds_metadata["vertical"]
			)
			cell_resource.initialize_object1_texture_and_offset(object1_sprite_texture, object1_offset)
			object1_tiles += 1

		if cell_resource.object2_id != 0:
			var object2_sprite_texture = asset_loader.get_object_sprite_texture(cell_resource.object2_id)
			var object2_bounds_metadata: Dictionary = asset_loader.get_object_sprite_metadata(cell_resource.object2_id)
			var object2_offset = Vector2( # TODO: Convert in SpriteMetadataResource
				object2_bounds_metadata["horizontal"],
				object2_bounds_metadata["vertical"]
			)
			cell_resource.initialize_object2_texture_and_offset(object2_sprite_texture, object2_offset)
			object2_tiles += 1

	# Scripted cells init
	var scripted_cells_data: Array[Dictionary] = database.get_scripted_cell_data(map_id)
	if scripted_cells_data.is_empty():
		push_warning("[MapManager] No scripted cells for map %d" % map_id)

	for scripted_cell_data in scripted_cells_data:
		var cell_resource = map_resource.cell_resources[scripted_cell_data["cell_id"]]
		cell_resource.initialize_action_properties(scripted_cell_data)

	if is_debug_mode:
		var debug_cell_actions = []
		for scripted_cell_data in scripted_cells_data:
			var cell_resource = map_resource.cell_resources[scripted_cell_data["cell_id"]]
			debug_cell_actions.append("- cell %s: action %s" % [cell_resource.id, cell_resource.action_resource.action_id])
		print("[MapManager] Scripted cells initialized:\n%s" % "\n".join(debug_cell_actions))


	# Battlefield
	battlefield.build_map(map_resource.background_texture, map_resource.size.x, map_resource.cell_resources, map_resource.diamond_grid_start, map_resource. diamond_grid_size)
	PerformanceTracker.end_timer()
	return true


func clear_map() -> void:
	datacenter.map_resource = null
	battlefield.clear()


## world path = results[0], directions = results[1]
func get_world_path_and_directions(p_from_cell_id: int, p_to_cell_id: int) -> Array[Array]:
	var map_resource: MapResource = datacenter.map_resource

	# Grid path
	var cell_id_path: PackedInt64Array = battlefield.spatial_handler.find_path(map_resource.size.x, p_from_cell_id, p_to_cell_id)

	var world_path: Array[Vector2] = []
	var directions: Array[SpatialHandler.Direction] = []
	for i in cell_id_path.size():
		var cell_id = cell_id_path[i]
		world_path.append(map_resource.cell_resources[cell_id].world_position)
		if i < cell_id_path.size() - 1:
			directions.append(battlefield.spatial_handler.get_direction_from_cell_id_to_cell_id(map_resource.size.x, cell_id, cell_id_path[i + 1]))
	
	# Results
	return [world_path, directions]


func highlight_cell() -> void:
	battlefield.highlight_cell()


## cell id -> cell world pos
func get_cell_world_position_from_cell_id(p_cell_id: int) -> Vector2:
	return datacenter.map_resource.cell_resources[p_cell_id].world_position


## cell world pos -> cell id
func get_cell_id_from_world_position(p_world_position: Vector2) -> int:
	var map_resource = datacenter.map_resource

	for cell_resource in map_resource.cell_resources:
		if p_world_position == cell_resource.world_position:
			return cell_resource.id

	push_error("[MapManager] Cell ID could not be retrieved for world position ", str(p_world_position))
	return -1


func get_current_map_id() -> int:
	if datacenter.map_resource != null:
		return datacenter.map_resource.map_id
	else:
		push_warning("[MapManager] No current map resource, cannot return map id")
		return -1


## Seems ok to have a method dedicated to send character (or other system) related variables
func get_current_map_npc_ids() -> Array[int]:
	return datacenter.map_resource.npc_ids


func _on_cell_clicked(cell_id: int) -> void:
	print("[MapManager] Cell clicked: %d" % cell_id)


func _on_cell_hovered(cell_id: int) -> void:
	# print("[MapManager] Cell hovered: %d" % cell_id)
	pass


func _on_cell_unhovered(cell_id: int) -> void:
	# print("[MapManager] Cell unhovered: %d" % cell_id)
	pass


func _on_character_manager_character_world_path_point_reached(p_world_position: Vector2, p_character_id: int) -> void:
	var cell_id = get_cell_id_from_world_position(p_world_position)
	datacenter.get_character_resource(p_character_id).cell_id = cell_id # update a **map** related variable on character
	var cell_resource: CellResource = datacenter.map_resource.cell_resources[cell_id]
	if cell_resource.action_resource != null:
		if is_debug_mode: print("[MapManager] Scripted cell triggered at cell ID %d with action id %s" % [cell_id, cell_resource.action_resource.action_id])
		scripted_cell_triggered.emit(cell_resource.action_resource)
