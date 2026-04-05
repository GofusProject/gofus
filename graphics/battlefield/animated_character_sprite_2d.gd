## mc.Sprite equivalent
class_name AnimatedCharacterSprite2D
extends AnimatedSprite2D


var is_debug_mode: bool = false
var previous_pos := Vector2(0,0)

var linked_character_id: int
var orientation_id: int
## Orientation letter is derived from orientation_id
var orientation_letter: String # L, R, B...
var animation_state_name: String # run, static...

# Cache to avoid get_image() every frame
var _cached_image: Image
var _cached_animation: StringName
var _cached_frame: int

# Interaction
var is_hovered: bool
var is_selected: bool
var area_2d: Area2D
var collision_shape: CollisionShape2D

# Visual
var sprite_metadata_resources: Dictionary[String, SpriteMetadataResource]

# Speed indexed by orientation_id
const WALK_SPEEDS = [0.07,0.06,0.06,0.06,0.07,0.06,0.06,0.06]
const MOUNT_SPEEDS = [0.23,0.2,0.2,0.2,0.23,0.2,0.2,0.2]
const RUN_SPEEDS = [0.17,0.15,0.15,0.15,0.17,0.15,0.15,0.15]
var speed_modifier: int = 48
var next_point: Vector2 = Vector2(-1, -1)
var path: Array[Vector2] = []
var path_directions: Array[CharacterSpriteHandler.Orientation]


signal hovered(animated_character_sprite_2d_id: int)
signal unhovered(animated_character_sprite_2d_id: int)
signal clicked(animated_character_sprite_2d_id: int)
signal world_path_point_reached(world_pos: Vector2, linked_character_id: int)



# Debug, uncomment to get position update
# func _physics_process(_delta):
# 	if global_position != previous_pos && is_debug_mode:
# 		print("[AnimatedCharacterSprite2D] New position: ", global_position)
# 	previous_pos = global_position


func _process(delta: float) -> void:
	if not path.is_empty():

		# si arrivé au prochain point on enlève le point du path
		if position.distance_to(next_point) == 0:
			world_path_point_reached.emit(next_point, linked_character_id)

			if not path.is_empty(): # Don't know why but happens when triggering a teleport cell
				path.remove_at(0)

			# If path empty, reset and return
			if path.is_empty():
				next_point = Vector2(-1, -1)
				play(_set_animation_to_play("static", orientation_id))
				return

			# Set next point
			next_point = path[0]

			path_directions.remove_at(0)
			orientation_id = path_directions[0]
			play(_set_animation_to_play("run", orientation_id))
		

		position = position.move_toward(next_point, RUN_SPEEDS[1] * speed_modifier ) # TO CHANGE


func initialize(p_linked_character_id: int, p_sprite_frames: SpriteFrames, p_sprite_metadata_resources: Dictionary[String, SpriteMetadataResource], p_direction: int) -> void:
	# World position is set by Actions.teleport()
	area_2d = get_node_or_null("Area2D")
	collision_shape = area_2d.get_node_or_null("CollisionShape2D")
	animation_changed.connect(_on_animation_changed)
	area_2d.input_event.connect(_on_area_2d_input_event)
	area_2d.mouse_exited.connect(_on_area_2d_mouse_exited)
	
	material = material.duplicate()
	set_highlight(false)

	linked_character_id	= p_linked_character_id
	orientation_id			= p_direction

	centered = false
	y_sort_enabled = true

	# Sprite frames resource
	sprite_frames = p_sprite_frames
	if sprite_frames == null:
		push_error("[", self, "] No sprite frames to display")
		return

	sprite_metadata_resources = p_sprite_metadata_resources

	var anim_to_play: String = _set_animation_to_play("static", orientation_id) # "static" is the default animation for npcs on map

	play(anim_to_play)

	# Force update because animation_changed triggers only if the animation set is different from the current animation. 
	# What happens is that offsets are not update in case that the first sprite frames animation is the one used at 
	# initialization because animation_changed does not trigger.
	_update_offset_and_area_2D()


func set_highlight(toggle: bool) -> void:
	if toggle == true: material.set_shader_parameter("highlight_opacity", 0.5)
	if toggle == false: material.set_shader_parameter("highlight_opacity", 0.0)


func follow_path(p_path: Array[Vector2], p_orientations: Array[CharacterSpriteHandler.Orientation]) -> void:
	path = p_path
	path_directions = p_orientations

	# allow the sprite to move from its position and the first next point (and not the first cell of the path)
	# If not remove, the sprite behave weirdly when the path is changed whil a path alreay exists
	path.remove_at(0)

	if path.is_empty():
		return
	
	orientation_id = path_directions[0]
	next_point = p_path[0]
	# Set orientation
	
	play(_set_animation_to_play("run", orientation_id))


func reset_movement() -> void:
	path.clear()
	next_point = Vector2(-1, -1)
	path_directions.clear()


func _set_animation_to_play(p_animation_state_name: String, orientation: int) -> String:

	var anim_to_play: String = p_animation_state_name

	flip_h = false
	match orientation:
		CharacterSpriteHandler.Orientation.EAST:
			anim_to_play += "S"
		CharacterSpriteHandler.Orientation.SOUTH_EAST:
			anim_to_play += "R"
		CharacterSpriteHandler.Orientation.SOUTH:
			anim_to_play += "F"
		CharacterSpriteHandler.Orientation.SOUTH_WEST:
			anim_to_play += "R"
			flip_h = true
		CharacterSpriteHandler.Orientation.WEST:
			anim_to_play += "S"
			flip_h = true
		CharacterSpriteHandler.Orientation.NORTH_WEST:
			anim_to_play += "L"
		CharacterSpriteHandler.Orientation.NORTH:
			anim_to_play += "B"
		CharacterSpriteHandler.Orientation.NORTH_EAST:
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


func _update_offset_and_area_2D() -> void:
	# update offset. Important to set as offset and not position for y sorting
	if sprite_metadata_resources.has(animation):
		offset = sprite_metadata_resources[animation].offset

	# update area 2D position and collision shape size
	var tex = sprite_frames.get_frame_texture(animation, frame)
	if not tex:
		return
	var tex_size = Vector2(tex.get_width(), tex.get_height())

	area_2d.position = tex_size / 2	+ offset

	if not collision_shape.shape is RectangleShape2D:
		collision_shape.shape = RectangleShape2D.new()
	(collision_shape.shape as RectangleShape2D).size = tex_size


func _on_animation_changed() -> void:
	_update_offset_and_area_2D()



func _on_area_2d_mouse_exited() -> void:
	# unhovering forcing
	if is_hovered != false:
		set_highlight(false)
		is_hovered = false
		unhovered.emit(linked_character_id)


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
			hovered.emit(linked_character_id)
		if event is InputEventMouseButton and event.pressed:
			is_selected = true
			get_viewport().set_input_as_handled() # Prevent cell area2D to trigger when clicking on a character area2D
			clicked.emit(linked_character_id)
	else:
		if is_hovered != false:
			set_highlight(false)
			is_hovered = false
			unhovered.emit(linked_character_id)

