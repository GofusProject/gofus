class_name UIMapInfos
extends VBoxContainer



var is_debug_mode: bool = false

@onready var area_names_label: Label = $AreaNamesLabel
@onready var map_position_label: Label = $MapPositionLabel



func update(p_area_name: String, p_sub_area_name: String, p_map_position: String) -> void:
	area_names_label.text = "%s (%s)" % [p_area_name, p_sub_area_name]
	map_position_label.text = "Coordonnées : " + p_map_position
