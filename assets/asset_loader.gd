## Manages loading and caching of assets (gfx, sprites...)

extends Node


const GROUND_TILES_PATH: String = "res://assets/graphics/gfx/grounds_scale_x2/"
const OBJECT_SPRITES_PATH: String = "res://assets/graphics/gfx/objects_scale_x2/"
const BACKGROUNDS_PATH: String = "res://assets/graphics/gfx/backgrounds_scale_x2/"
const CHARACTER_SPRITES_PATH: String = "res://assets/graphics/characters/"

const CHARACTER_SPRITES_METADATA_PATH: String = "res://assets/graphics/characters/character_sprite_metadata.json"
const GROUND_METADATA_PATH: String = "assets/graphics/gfx/grounds_scale_x2/ground_metadatas.json"
const OBJECT_BOUNDS_PATH: String = "assets/graphics/gfx/objects_scale_x2/o_bounds_x2.json"

# ASSET CACHE
var _ground_tile_cache: Dictionary = {}
var _object_sprite_cache: Dictionary = {}
var _background_cache: Dictionary = {}
var _character_sprite_frames_cache: Dictionary = {}

var _character_sprite_metadata_cache: Dictionary[int, Dictionary] = {}
var _ground_metadata_cache: Dictionary[int, Dictionary] = {}
var _object_bounds_cache: Dictionary[int, Dictionary] = {}


func _ready() -> void:
	_load_all_character_sprites_metadata()
	_load_all_ground_sprites_metadata()
	_load_all_object_sprites_bounds()


func _get_json_from_file(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("[AssetLoader] Error opening file: " + path + ", Error code:", FileAccess.get_open_error())
		return {}
	var json: JSON = JSON.new()
	var error = json.parse(file.get_as_text())
	file.close()
	if error != OK:
		print("[AssetLoader] Error parsing JSON at: " + path + ". Line:", json.get_error_line(), ". Message:", json.get_error_message())
		return {}
	return json.data


func _load_all_character_sprites_metadata() -> void:
	var data: Dictionary = _get_json_from_file(CHARACTER_SPRITES_METADATA_PATH)
	if data.is_empty():
		return
	for character_sprite_id_str in data.keys():
		var character_sprite_id: int = character_sprite_id_str.to_int()
		var anim_metadata_raw = data[character_sprite_id_str]
		var anim_metadata_typed: Dictionary[String, Dictionary] = {}
		for anim_name in anim_metadata_raw.keys():
			var anim_data = anim_metadata_raw[anim_name]
			anim_metadata_typed[anim_name] = {
				"horizontal": float(anim_data.get("horizontal", 0.0)),
				"vertical": float(anim_data.get("vertical", 0.0)),
				"frames": int(anim_data.get("frames", 0))
			}
		_character_sprite_metadata_cache[character_sprite_id] = anim_metadata_typed


func _load_all_ground_sprites_metadata() -> void:
	var data: Dictionary = _get_json_from_file(GROUND_METADATA_PATH)
	if data.is_empty():
		return
	for d in data:
		var entry = data[d]
		_ground_metadata_cache[int(d)] = {
			"frame_count": int(entry["frame_count"]),
			"horizontal": int(entry["horizontal"]),
			"vertical": int(entry["vertical"])
		}


func _load_all_object_sprites_bounds() -> void:
	var data: Dictionary = _get_json_from_file(OBJECT_BOUNDS_PATH)
	if data.is_empty():
		return
	for d in data:
		var entry = data[d]
		_object_bounds_cache[int(d)] = {
			"horizontal": int(entry["horizontal"]),
			"vertical": int(entry["vertical"])
		}


## For pngs
func _get_cached_texture(cache: Dictionary, base_path: String, asset_id: int, label: String) -> Texture2D:
	if asset_id == 0:
		return null
	if not cache.has(asset_id):
		var path := base_path + "%d.png" % asset_id
		if ResourceLoader.exists(path):
			cache[asset_id] = load(path)
		else:
			push_warning("[AssetLoader] %s not found: %s" % [label, path])
			return null
	return cache[asset_id]


func get_ground_tile_texture(tile_id: int) -> Texture2D:
	return _get_cached_texture(_ground_tile_cache, GROUND_TILES_PATH, tile_id, "Ground tile")


func get_object_sprite_texture(sprite_id: int) -> Texture2D:
	return _get_cached_texture(_object_sprite_cache, OBJECT_SPRITES_PATH, sprite_id, "Object sprite")


func get_background_texture(bg_id: int) -> Texture2D:
	return _get_cached_texture(_background_cache, BACKGROUNDS_PATH, bg_id, "Background")


## Sprite frames
func get_character_sprite_frames(sprite_frames_id: int) -> SpriteFrames:

	if not _character_sprite_frames_cache.has(sprite_frames_id):
		var path: String = CHARACTER_SPRITES_PATH + "%d/%d.tres" % [sprite_frames_id, sprite_frames_id]

		if ResourceLoader.exists(path):
			_character_sprite_frames_cache[sprite_frames_id] = load(path)
		else:
			push_error("[AssetLoader] Character sprite frames not found: " + path)
			return null

	return _character_sprite_frames_cache[sprite_frames_id]


# Metadata
func get_character_sprite_offset(sprite_frames_id: int, anim: String) -> Vector2:

	# Get Sprite frames metadata
	if not _character_sprite_metadata_cache.has(sprite_frames_id):
		print("[AssetLoader] Sprite frames id not found:", sprite_frames_id)
		return Vector2.ZERO

	var character_sprite_metadata: Dictionary = _character_sprite_metadata_cache[sprite_frames_id]

	# Get animation metadata
	if not character_sprite_metadata.has(anim):
		print("[AssetLoader] Animation not found for sprite frames", sprite_frames_id, "anim:", anim)
		return Vector2.ZERO

	var anim_metadata: Dictionary = character_sprite_metadata[anim]

	# Get bounds
	var horizontal: float = float(anim_metadata.get("horizontal", 0.0))
	var vertical: float = float(anim_metadata.get("vertical", 0.0))

	# Return
	return Vector2(horizontal, vertical)


func get_ground_sprite_metadata(ground_id: int) -> Dictionary:
	if not _ground_metadata_cache.has(ground_id):
		print("[AssetLoader] Ground id not found:", ground_id)
		return {}
	return _ground_metadata_cache[ground_id]


func get_object_sprite_metadata(object_id: int) -> Dictionary:
	if not _object_bounds_cache.has(object_id):
		print("[AssetLoader] Object id not found:", object_id)
		return {}
	return _object_bounds_cache[object_id]
