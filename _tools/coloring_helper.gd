@tool
class_name ColoringHelper
extends Node


@export var CHARACTER_SPRITES_METADATA_PATH: String = "res://assets/graphics/characters/character_sprite_metadata.json"

@export var sprite_frames_id: String = ""
@export var anim_name: String = ""
@export var sprite_frames_id_to_create: String = ""
@export var copy_anim_metadata_to_id_toggle: bool = false:
	set(v):
		if v and Engine.is_editor_hint():
			copy_anim_metadata_to_id()
		copy_anim_metadata_to_id_toggle = false


func print_color_data(character_id: int) -> void:
	var char_res: CharacterResource = Game.datacenter.get_character_resource(character_id)
	print("Npc template ID: ", char_res.npc_template_id)
	print("Hex Color1 (Head): %X | Hex Color2 (Body): %X | Hex Color3 (Bottom): %X" % [char_res.color1, char_res.color2, char_res.color3])
	print("Sprite frames id: ", char_res.sprite_frames_id)


func copy_anim_metadata_to_id() -> void:

	var file = FileAccess.open(CHARACTER_SPRITES_METADATA_PATH, FileAccess.READ)
	if file == null:
		print("Error opening file: " + CHARACTER_SPRITES_METADATA_PATH + ", Error code:", FileAccess.get_open_error())
		return

	var json: JSON = JSON.new()
	var error = json.parse(file.get_as_text())
	if error != OK:
		print("Error parsing JSON at: " + CHARACTER_SPRITES_METADATA_PATH + ". Line:", json.get_error_line(), ". Message:", json.get_error_message())
		return
	file.close()

	# Get character sprite metadata
	var data = json.data as Dictionary
	if not data.has(sprite_frames_id):
		print("Sprite frames id not found:", sprite_frames_id)

		return
	var character_sprite_metadata = data.get(sprite_frames_id)

	# Get animation metadata
	if not character_sprite_metadata.has(anim_name):
		print("Animation not found for sprite frames", sprite_frames_id, "anim_name:", anim_name)

		return
	var anim_metadata: Dictionary = character_sprite_metadata[anim_name]


	# Assign the animation metadata
	if not data.has(sprite_frames_id_to_create):
		data[sprite_frames_id_to_create] = {}
	data[sprite_frames_id_to_create][anim_name] = anim_metadata


	# Write in file
	file = FileAccess.open(CHARACTER_SPRITES_METADATA_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

	print(str(anim_metadata) + " saved to " + str(sprite_frames_id_to_create))