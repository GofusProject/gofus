# MapManager.gd
# AutoLoad singleton
# Orchestrates map loading by coordinating Database, Compressor, and Datacenter to build MapResource
extends Node


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
	Battlefield.render_map()
	return true


func clear_map() -> void:
	Datacenter.current_map_resource = null
	Battlefield.clear_map()
