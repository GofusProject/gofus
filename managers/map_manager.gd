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
	
	print("[MapManager] Current map resource : width=%d, height=%d, bgID=%d, cell count=%d" % [map_resource.width, map_resource.height, map_resource.background_id, map_resource.cell_count])
	
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

	Battlefield.render_map(map_resource.background_id, map_resource.cell_resources)
	return true


func clear_map() -> void:
	Datacenter.current_map_resource = null
	Battlefield.clear_map()


func get_cell_id_from_mouse_position() -> int:
	var map_resource = Datacenter.current_map_resource
	var cell_resources: Array[CellResource] = map_resource.cell_resources

	return Battlefield.get_cell_id_from_world_position(cell_resources)


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