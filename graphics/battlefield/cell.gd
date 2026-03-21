class_name Cell
extends Node2D


var linked_character_id: int
var id: int


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("[Cell] Cell %s clicked !" % id)


func _on_area_2d_mouse_exited() -> void:
	print("[Cell] Cell %s exited" % id)


func _on_area_2d_mouse_entered() -> void:
	print("[Cell] Cell %s entered" % id)
