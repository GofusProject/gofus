@tool
class_name AnimatedCharacterSprite2dTester
extends Node2D

var test_animated_character_sprite_2d: AnimatedCharacterSprite2D
@export var resource_name: String = ""
@export var animation_name: String = ""
var asset_loader: AssetLoader


func _ready() -> void:
	asset_loader = AssetLoader.new()

	test_animated_character_sprite_2d = add_animated_character_sprite_2d(1, 10, 1)


	# Add a button for changing animation resource
	var resource_button = Button.new()
	resource_button.text = "Change Resource"
	resource_button.pressed.connect(_on_resource_button_pressed)
	add_child(resource_button)
	resource_button.position = Vector2(100, 100) # Adjust position as needed

	# Add a button for changing animation
	var animation_button = Button.new()
	animation_button.text = "Change Animation"
	animation_button.pressed.connect(_on_animation_button_pressed)
	add_child(animation_button)
	animation_button.position = Vector2(100, 200) # Adjust position as needed



func _on_resource_button_pressed() -> void:
	test_animated_character_sprite_2d.sprite_frames = asset_loader.get_character_sprite_frames(int(resource_name))


func _on_animation_button_pressed() -> void:
	if test_animated_character_sprite_2d and test_animated_character_sprite_2d.sprite_frames.has_animation(animation_name):
		test_animated_character_sprite_2d.play(animation_name)
	else:
		print("Animation not found or sprite not initialized")

# func add_animated_character_sprite_2d(character_resource: CharacterResource) -> void:
func add_animated_character_sprite_2d(p_linked_character_id: int, p_sprite_frames_id: int, p_direction: int) -> AnimatedCharacterSprite2D:

	var animated_character_sprite_2d: AnimatedCharacterSprite2D = Battlefield.ANIMATED_CHARACTER_SPRITE_2D_SCENE.instantiate()
	animated_character_sprite_2d.initialize(p_linked_character_id, p_sprite_frames_id, p_direction)

	# animated_character_sprite_2d.position = Battlefield.get_world_position_from_cell_id(character_resource.cell_id)
	# Battlefield.character_sprites.add_child(animated_character_sprite_2d)
	animated_character_sprite_2d.position = Vector2(500, 500) # TO REMOVE
	add_child(animated_character_sprite_2d) # TO REMOVE
	return animated_character_sprite_2d # TO REMVOE
