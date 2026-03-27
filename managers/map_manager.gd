# MapManager.gd
# AutoLoad singleton
# Orchestrates map loading by coordinating Database, Compressor, and Datacenter to build MapResource
extends Node


# Counters for statistics
var ground_tiles: int = 0
var object1_tiles: int = 0
var object2_tiles: int = 0


func _ready() -> void:
	print("[MapManager] Ready")
	Battlefield.cell_clicked.connect(_on_cell_clicked)
	Battlefield.cell_hovered.connect(_on_cell_hovered)
	Battlefield.cell_unhovered.connect(_on_cell_unhovered)


## Orchestrate map creation process
## Return true if map successfully created, false if not
func create_map(map_id: int) -> bool:
	print("[MapManager] Creating map %d..." % map_id)
	
	# 1. Database
	var map_dict: Dictionary = Database.get_map_data(map_id)
	if map_dict.is_empty():
		push_error("[MapManager] No map dictionary for map %d" % map_id)
		return false
	
	# 2. Datacenter and MapResource and CellResources
	var map_resource: MapResource = MapResource.new(map_dict)
	if map_resource.cell_count == 0:
		push_error("[MapManager] MapResource initialization failed for map %d" % map_id)
		return false
	
	print("[MapManager] Current map resource : width=%d, height=%d, bgID=%d, cell count=%d" % [map_resource.staggered_width, map_resource.staggered_height, map_resource.background_id, map_resource.cell_count])
	
	Datacenter.set_current_map_resource(map_resource)

	# 3. Battlefield, AssetLoader and CellResource (2nd init)

	for cell_resource in map_resource.cell_resources:

		if cell_resource.ground_tile_id != 0:
			var ground_texture = AssetLoader.get_ground_tile_texture(cell_resource.ground_tile_id)
			var ground_sprite_metadata: Dictionary = AssetLoader.get_ground_sprite_metadata(cell_resource.ground_tile_id)
			var ground_offset = Vector2(
				ground_sprite_metadata["horizontal"],
				ground_sprite_metadata["vertical"]
			)
			var ground_hframes = ground_sprite_metadata["frame_count"]
			cell_resource.initialize_ground_texture_and_offset(ground_texture, ground_offset, ground_hframes)
			ground_tiles += 1

		if cell_resource.object1_id != 0:
			var object1_sprite_texture = AssetLoader.get_object_sprite_texture(cell_resource.object1_id)
			var object1_bounds_metadata: Dictionary = AssetLoader.get_object_sprite_metadata(cell_resource.object1_id)
			var object1_offset = Vector2(
				object1_bounds_metadata["horizontal"],
				object1_bounds_metadata["vertical"]
			)
			cell_resource.initialize_object1_texture_and_offset(object1_sprite_texture, object1_offset)
			object1_tiles += 1

		if cell_resource.object2_id != 0:
			var object2_sprite_texture = AssetLoader.get_object_sprite_texture(cell_resource.object2_id)
			var object2_bounds_metadata: Dictionary = AssetLoader.get_object_sprite_metadata(cell_resource.object2_id)
			var object2_offset = Vector2(
				object2_bounds_metadata["horizontal"],
				object2_bounds_metadata["vertical"]
			)
			cell_resource.initialize_object2_texture_and_offset(object2_sprite_texture, object2_offset)
			object2_tiles += 1

	Battlefield.render_map(map_resource.background_id, map_resource.cell_resources, map_resource.diamond_grid_start, map_resource.diamond_grid_size)
	return true


func clear_map() -> void:
	Datacenter.map_resource = null
	Battlefield.clear_map()


func find_path(p_from_cell_id: int, p_to_cell_id: int) -> Array[Vector2]:
	var map_resource: MapResource = Datacenter.map_resource
	var from_cell_grid_pos: Vector2i = Vector2i.ZERO
	var to_cell_grid_pos: Vector2i = Vector2i.ZERO

	for cell_resource: CellResource in map_resource.cell_resources:
		if p_from_cell_id == cell_resource.id:
			from_cell_grid_pos = Vector2i(cell_resource.diamond_grid_x, cell_resource.diamond_grid_y)
		if p_to_cell_id == cell_resource.id:
			to_cell_grid_pos = Vector2i(cell_resource.diamond_grid_x, cell_resource.diamond_grid_y)

	if from_cell_grid_pos == Vector2i.ZERO or to_cell_grid_pos == Vector2i.ZERO:
		printerr("[MapManager] Could not find path (from cell ids: %s, to: %s)" % [p_from_cell_id, p_to_cell_id])
		return []

	print("[MapManager] From cell %d (grid pos %s) to cell %d (grid pos %s)" % [p_from_cell_id, from_cell_grid_pos, p_to_cell_id, to_cell_grid_pos])
	var path: Array[Vector2i] = Battlefield.find_grid_path(from_cell_grid_pos, to_cell_grid_pos)
	print("[MapManager] Path found: %s" % str(path))

	# TO DO, retrieve array cell by grid pos and get world position
	return []


func highlight_cell() -> void:
	Battlefield.highlight_cell()


func _on_cell_clicked(cell_id: int) -> void:
	print("[MapManager] Cell clicked: %d" % cell_id)


func _on_cell_hovered(cell_id: int) -> void:
	# print("[MapManager] Cell hovered: %d" % cell_id)
	pass


func _on_cell_unhovered(cell_id: int) -> void:
	# print("[MapManager] Cell unhovered: %d" % cell_id)
	pass
