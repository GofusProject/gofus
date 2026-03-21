## mc.Sprite equivalent
class_name AnimatedCharacterSprite2D
extends AnimatedSprite2D

var linked_character_id: int
var sprite_frames_id: int
var direction: int

# Cache to avoid get_image() every frame
var _cached_image: Image
var _cached_animation: StringName
var _cached_frame: int

var is_hovered: bool

var is_selected: bool
var area_2d: Area2D
var collision_shape: CollisionShape2D


signal hovered(animated_character_sprite_2d: AnimatedCharacterSprite2D)
signal unhovered(animated_character_sprite_2d: AnimatedCharacterSprite2D)
signal clicked(animated_character_sprite_2d: AnimatedCharacterSprite2D)


func initialize(p_linked_character_id: int, p_sprite_frames_id: int, p_direction: int) -> void:
	area_2d = get_node_or_null("Area2D")
	collision_shape = area_2d.get_node_or_null("CollisionShape2D")
	animation_changed.connect(_on_animation_changed)
	area_2d.input_event.connect(_on_area_2d_input_event)
	area_2d.mouse_exited.connect(_on_area_2d_mouse_exited)
	
	material = material.duplicate()
	set_highlight(false)

	linked_character_id	= p_linked_character_id
	sprite_frames_id	= p_sprite_frames_id
	direction			= p_direction

	centered = false
	y_sort_enabled = true

	# Sprite frames resource
	sprite_frames = AssetLoader.get_character_sprite_frames(sprite_frames_id)
	if sprite_frames == null:
		push_error("[", self, "] No sprite frames to display")
		return

	var anim_to_play: String = _set_animation_to_play("static", direction) # "static" is the default animation for npcs on map

	play(anim_to_play)


func set_highlight(toggle: bool) -> void:
	if toggle == true: material.set_shader_parameter("highlight_opacity", 0.5)
	if toggle == false: material.set_shader_parameter("highlight_opacity", 0.0)
	

func _set_animation_to_play(animation_state_name: String, direction_letter: int) -> String:

	var anim_to_play: String = animation_state_name

	match direction_letter:
		CharacterSpriteHandler.Direction.EAST:
			anim_to_play += "S"
		CharacterSpriteHandler.Direction.SOUTH_EAST:
			anim_to_play += "R"
		CharacterSpriteHandler.Direction.SOUTH:
			anim_to_play += "F"
		CharacterSpriteHandler.Direction.SOUTH_WEST:
			anim_to_play += "R"
			flip_h = true
		CharacterSpriteHandler.Direction.WEST:
			anim_to_play += "S"
			flip_h = true
		CharacterSpriteHandler.Direction.NORTH_WEST:
			anim_to_play += "L"
		CharacterSpriteHandler.Direction.NORTH:
			anim_to_play += "B"
		CharacterSpriteHandler.Direction.NORTH_EAST:
			anim_to_play += "L"
			flip_h = true

	return anim_to_play
	

func _is_pixel_opaque(global_mouse: Vector2) -> bool:

	# Create or get cached image MAYBE TO REMOVE
	if animation != _cached_animation or frame != _cached_frame:
		_cached_animation = animation
		_cached_frame = frame
		var tex = sprite_frames.get_frame_texture(animation, frame)
		_cached_image = tex.get_image() if tex else null
	var image = _cached_image
	if not image:
		return false

	var tex_size = Vector2(image.get_width(), image.get_height())
	var local = to_local(global_mouse)
	var pixel_pos = local - offset

	# Flip
	if flip_h: # PAS SUR QUE CE SOIT UTILE
		pixel_pos.x = tex_size.x - pixel_pos.x
	if flip_v:
		pixel_pos.y = tex_size.y - pixel_pos.y

	# Bounds check
	if pixel_pos.x < 0 or pixel_pos.y < 0:
		return false
	if pixel_pos.x >= tex_size.x or pixel_pos.y >= tex_size.y:
		return false

	var a = image.get_pixel(int(pixel_pos.x), int(pixel_pos.y)).a
	return a > 0.1


func _on_animation_changed() -> void:

	# update offset. Important to set as offset and not position for y sorting
	offset = AssetLoader.get_character_sprite_bounds(sprite_frames_id, animation)

	# update area 2D position and collision shape size
	var tex = sprite_frames.get_frame_texture(animation, frame)
	if not tex:
		return
	var tex_size = Vector2(tex.get_width(), tex.get_height())

	area_2d.position = tex_size / 2	+ offset

	if not collision_shape.shape is RectangleShape2D:
		collision_shape.shape = RectangleShape2D.new()
	(collision_shape.shape as RectangleShape2D).size = tex_size


func _on_area_2d_mouse_exited() -> void:
	# unhovering forcing
	if is_hovered != false:
		set_highlight(false)
		is_hovered = false
		unhovered.emit(self)


func _on_area_2d_mouse_entered() -> void:
	# hovering forcing
	if _is_pixel_opaque(get_global_mouse_position()):
			if is_hovered != true:
				set_highlight(true)
				is_hovered = true
				hovered.emit(self)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if _is_pixel_opaque(get_global_mouse_position()):
		if is_hovered != true:
			set_highlight(true)
			is_hovered = true
			hovered.emit(self)
		if event is InputEventMouseButton and event.pressed:
			is_selected = true
			clicked.emit(self)
	else:
		if is_hovered != false:
			set_highlight(false)
			is_hovered = false
			unhovered.emit(self)
