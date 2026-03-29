extends Node


var _start_time: int = 0
var _class_name: String = ""
var _sentence: String = ""


func start_timer(p_class_name: String, p_sentence: String = "") -> void:
	_class_name = p_class_name
	_sentence = p_sentence if p_sentence != "" else "Total"
	_start_time = Time.get_ticks_usec()


func end_timer() -> void:
	var elapsed: int = Time.get_ticks_usec() - _start_time
	var elapsed_sec: float = elapsed / 1000000.0
	var frame_pct: float = (elapsed_sec / (1.0 / 48.0)) * 100.0
	print("[%s] %s: %s seconds | Frame percentage (48hz): %s%%" % [
		_class_name,
		_sentence,
		elapsed_sec,
		frame_pct
	])

	_start_time = 0
	_class_name = ""
	_sentence = ""
