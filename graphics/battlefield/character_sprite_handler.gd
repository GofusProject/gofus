class_name CharacterSpriteHandler
extends Node2D

enum Direction {
	EAST = 0,
	SOUTH_EAST = 1,
	SOUTH = 2,
	SOUTH_WEST = 3,
	WEST = 4,
	NORTH_WEST = 5,
	NORTH = 6,
	NORTH_EAST = 7
}


func add_animated_character_sprite_2d(p_linked_character_id: int, p_sprite_frames_id: int, p_direction: int, p_cell_id: int) -> void:

	var animated_character_sprite_2d = Battlefield.ANIMATED_CHARACTER_SPRITE_2D_SCENE.instantiate()
	animated_character_sprite_2d.initialize(p_linked_character_id, p_sprite_frames_id, p_direction)
	animated_character_sprite_2d.position = Battlefield.get_world_position_from_cell_id(p_cell_id)

	animated_character_sprite_2d.hovered.connect(Battlefield._on_animated_character_sprite_2d_hovered)
	animated_character_sprite_2d.unhovered.connect(Battlefield._on_animated_character_sprite_2d_unhovered)
	animated_character_sprite_2d.clicked.connect(Battlefield._on_animated_character_sprite_2d_clicked)

	Battlefield.character_sprites.add_child(animated_character_sprite_2d)


func clear_character_sprites() -> void:
	for child in Battlefield.character_sprites.get_children():
		child.queue_free()


func get_animated_character_sprite_2d_by_character_id(p_character_id: int) -> AnimatedCharacterSprite2D:
	for child in Battlefield.character_sprites.get_children():
		if child.linked_character_id == p_character_id:
			return child
	push_error("[CharacterSpriteHandler] No AnimatedCharacterSprite2D found for character id %d" % p_character_id)
	return null


func get_animated_character_sprite_2d_world_position(p_character_id: int) -> Vector2:
	var animated_character_sprite_2d: AnimatedCharacterSprite2D = get_animated_character_sprite_2d_by_character_id(p_character_id)
	return animated_character_sprite_2d.position