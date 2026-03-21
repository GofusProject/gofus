class_name OverHeadHandler
extends Node


var over_head_y = -50


func create_over_head(p_animated_character_sprite_2d: AnimatedCharacterSprite2D, p_name: String) -> void:
	var text_over_head = Battlefield.TEXT_OVER_HEAD_SCENE.instantiate()
	Battlefield.over_head_layer.add_child(text_over_head)

	# Text
	var label: Label = text_over_head.get_node_or_null("Background/Label")
	label.text = p_name

	# Position
	var tex = p_animated_character_sprite_2d.sprite_frames.get_frame_texture(p_animated_character_sprite_2d.animation, p_animated_character_sprite_2d.frame)
	var half_image_x = tex.get_image().get_width() / 2
	text_over_head.position = p_animated_character_sprite_2d.position \
		+ p_animated_character_sprite_2d.offset \
		+ Vector2(half_image_x, over_head_y)


func destroy_all_over_head() -> void:
	for child in Battlefield.over_head_layer.get_children():
		child.queue_free()