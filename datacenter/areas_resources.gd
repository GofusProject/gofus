## Resource that handles subareas, areas and super areas data
class_name AreaResources
extends Resource



var is_debug_mode: bool = true

var sub_area_id: int
var music_id: int
var neighbour_sub_area_ids: Array[int] = []
var sub_area_name: String

var area_id: int
var area_name: String

var super_area_id: int
var super_area_name: String


func _init(p_sub_area_data: Dictionary, p_area_data: Dictionary, p_super_area_data: Dictionary, p_sub_area_name: String, p_area_name: String, p_super_area_name: String) -> void:
	if is_debug_mode: print("[AreaResources] Initializing AreaResources with sub area data:\n - %s\n - area data: %s\n - super area data: %s" % [p_sub_area_data, p_area_data, p_super_area_data])

	sub_area_id = int(p_sub_area_data["id"])
	music_id = int(p_sub_area_data["music_id"])
	if p_sub_area_data["neighboring_subarea_ids"] != "":  
		for s in p_sub_area_data["neighboring_subarea_ids"].split("|"):
			neighbour_sub_area_ids.append(int(s))
	sub_area_name = p_sub_area_name		

	area_id = int(p_area_data["id"])
	area_name = p_area_name

	super_area_id = int(p_super_area_data["id"])
	super_area_name = p_super_area_name

	super_area_id = int(p_super_area_data["id"])
