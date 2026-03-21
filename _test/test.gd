@tool
extends Node2D

@export var draw_test: Node2D

@export var npc_template_data_init_question: String
@export var queue_redraw_toggle: bool = false:
	set(v):
		if v and Engine.is_editor_hint():
			draw_with_draw_test()
			pass
		queue_redraw_toggle = false


func draw_with_draw_test():
	draw_test.draw_line(Vector2(250, 250), Vector2(500, 500), Color.WHITE, 1.5)
	draw_test.queue_redraw()