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


## Orchestrate map creation process
## Return true if map successfully created, false if not
func create_map(map_id: int) -> bool:
	print("[MapManager] Creating map %d..." % map_id)
	
	var map_dict: Dictionary = Database.get_map_data(map_id)
	if map_dict.is_empty():
		push_error("[MapManager] No map dictionary for map %d" % map_id)
		return false
	
	var map_resource: MapResource = MapResource.new(map_dict)
	if map_resource.cell_count == 0:
		push_error("[MapManager] MapResource initialization failed for map %d" % map_id)
		return false
	
	print("[MapManager] Current map resource : width=%d, height=%d, bgID=%d, cell count=%d" % [map_resource.width, map_resource.height, map_resource.background_id, map_resource.cell_count])
	
	Datacenter.set_current_map_resource(map_resource)

	var cell_visual_resources: Array[CellVisualResource] = []

	for cell_resource in map_resource.cell_resources:
		var cell_visual_resource = CellVisualResource.new(cell_resource)
		cell_visual_resources.append(cell_visual_resource)

	Battlefield.render_map(cell_visual_resources)
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
