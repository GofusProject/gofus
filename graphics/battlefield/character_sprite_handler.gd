## As all Battlefield handler exept SpatialHandler, CharacterSpriteHandler can only process world position (no grid position)

class_name CharacterSpriteHandler
extends Node2D


signal character_hovered(animated_character_sprite_2d_id: int)
signal character_unhovered(animated_character_sprite_2d_id: int)
signal character_clicked(animated_character_sprite_2d_id: int)
signal character_world_path_point_reached(world_pos: Vector2, linked_character_id: int)


enum Orientation {
	EAST = 0,
	SOUTH_EAST = 1,
	SOUTH = 2,
	SOUTH_WEST = 3,
	WEST = 4,
	NORTH_WEST = 5,
	NORTH = 6,
	NORTH_EAST = 7
}



func add_animated_character_sprite_2d(p_linked_character_id: int, p_sprite_frames: SpriteFrames, p_character_sprite_metadata: Dictionary[String, SpriteMetadataResource], p_direction: int, p_cell_id: int, p_player_character_layer: bool = false) -> void:

	var animated_character_sprite_2d = Battlefield.ANIMATED_CHARACTER_SPRITE_2D_SCENE.instantiate()
	animated_character_sprite_2d.initialize(p_linked_character_id, p_sprite_frames, p_character_sprite_metadata, p_direction)
	animated_character_sprite_2d.position = MapManager.get_cell_world_position_from_cell_id(p_cell_id) # Position should be a parameter

	animated_character_sprite_2d.hovered.connect(func(animated_character_sprite_2d_id: int) -> void:
		character_hovered.emit(animated_character_sprite_2d_id)
	)
	animated_character_sprite_2d.unhovered.connect(func(animated_character_sprite_2d_id: int) -> void:
		character_unhovered.emit(animated_character_sprite_2d_id)
	)
	animated_character_sprite_2d.clicked.connect(func(animated_character_sprite_2d_id: int) -> void:
		character_clicked.emit(animated_character_sprite_2d_id)
	)
	animated_character_sprite_2d.world_path_point_reached.connect(func(world_pos: Vector2, linked_character_id: int) -> void:
		character_world_path_point_reached.emit(world_pos, linked_character_id)
	)

	if p_player_character_layer == false:
		Battlefield.character_sprites.add_child(animated_character_sprite_2d)
	else:
		Battlefield.player_character_layer.add_child(animated_character_sprite_2d)


func clear() -> void:
	for child in Battlefield.character_sprites.get_children():
		child.queue_free()


func get_animated_character_sprite_2d_by_character_id(p_character_id: int) -> AnimatedCharacterSprite2D:
	for child in Battlefield.character_sprites.get_children():
		if child.linked_character_id == p_character_id:
			return child
	for child in Battlefield.player_character_layer.get_children():
		if child.linked_character_id == p_character_id:
			return child	
	push_error("[CharacterSpriteHandler] No AnimatedCharacterSprite2D found for character id %d" % p_character_id)
	return null


func get_animated_character_sprite_2d_world_position(p_character_id: int) -> Vector2:
	var animated_character_sprite_2d: AnimatedCharacterSprite2D = get_animated_character_sprite_2d_by_character_id(p_character_id)
	return animated_character_sprite_2d.position


func move_character(p_character_id: int, p_path: Array[Vector2],  p_orientations: Array[CharacterSpriteHandler.Orientation]) -> void:
	var animated_character_sprite_2d: AnimatedCharacterSprite2D = get_animated_character_sprite_2d_by_character_id(p_character_id)
	animated_character_sprite_2d.follow_path(p_path, p_orientations)


func teleport_character(p_character_id: int, p_world_position: Vector2) -> void:
	var animated_character_sprite_2d: AnimatedCharacterSprite2D = get_animated_character_sprite_2d_by_character_id(p_character_id)
	animated_character_sprite_2d.reset_movement()
	animated_character_sprite_2d.position = p_world_position
