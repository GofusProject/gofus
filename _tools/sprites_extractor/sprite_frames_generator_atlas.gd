@tool
extends Node
## ─────────────────────────────────────────────
##  SpriteFrames Generator
##  Attach to any Node in the scene, then click
##  "Generate All SpriteFrames" in the Inspector.
## ─────────────────────────────────────────────
@export var character_sprites_metadata_path: String = "res://_tools/sprites_extractor/sprite_sheet_generator_output/character_sprite_metadata.json"
## Root folder that contains all character subfolders (1197, 1212…)
@export var characters_root_path: String = "res://characters/"
## Frames per second for every animation
const DEFAULT_FPS := 48
## If true, existing .tres files will be overwritten. If false, they will be skipped.
@export var overwrite_existing: bool = false
## Only update these animations (e.g. ["staticR", "staticL"]). Leave empty to update ALL animations.
## overwrite_existing is bypassed when a filter is active.
@export var animations_filter: Array[String] = []
@export var generate: bool = false:
	set(v):
		if v and Engine.is_editor_hint():
			_run()
		generate = false

func _run() -> void:
	# ── Load the shared metadata.json once ───────────────────────────────────
	if not FileAccess.file_exists(character_sprites_metadata_path):
		push_error("SpriteFramesGenerator: metadata.json not found at '%s'" % character_sprites_metadata_path)
		return
	var file := FileAccess.open(character_sprites_metadata_path, FileAccess.READ)
	var json  := JSON.new()
	var err   := json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_error("SpriteFramesGenerator: failed to parse metadata.json")
		return
	var all_metadata: Dictionary = json.data

	if animations_filter.is_empty():
		print("SpriteFramesGenerator: no filter set — updating ALL animations.")
	else:
		print("SpriteFramesGenerator: filter active — only updating: %s" % str(animations_filter))

	# ── Iterate character folders ─────────────────────────────────────────────
	var dir : DirAccess = DirAccess.open(characters_root_path)
	if dir == null:
		push_error("SpriteFramesGenerator: cannot open '%s'" % characters_root_path)
		return
	dir.list_dir_begin()
	var entry : String = dir.get_next()
	while entry != "":
		if dir.current_is_dir() and not entry.begins_with("."):
			_process_character(entry, all_metadata)
		entry = dir.get_next()
	dir.list_dir_end()
	print("SpriteFramesGenerator: done.")

func _process_character(folder_name: String, all_metadata: Dictionary) -> void:
	var char_path : String = characters_root_path.path_join(folder_name)
	var tres_path := char_path.path_join(folder_name + ".tres")
	var is_filter_active := not animations_filter.is_empty()

	# ── Load existing SpriteFrames or create a new one ────────────────────────
	var sprite_frames: SpriteFrames
	if is_filter_active and FileAccess.file_exists(tres_path):
		# Partial update: load the existing resource so we preserve other animations
		sprite_frames = load(tres_path)
		if sprite_frames == null:
			push_error("SpriteFramesGenerator: failed to load existing .tres at '%s'" % tres_path)
			return
		print("SpriteFramesGenerator: partial update on '%s'" % tres_path)
	else:
		# Full update path — respect overwrite_existing flag
		if FileAccess.file_exists(tres_path):
			if not overwrite_existing:
				print("SpriteFramesGenerator: skipping '%s' (already exists, overwrite_existing=false)" % tres_path)
				return
			else:
				print("SpriteFramesGenerator: overwriting '%s'" % tres_path)
		sprite_frames = SpriteFrames.new()
		sprite_frames.remove_animation("default")

	# ── Look up this character's metadata by folder name (e.g. "1197") ───────
	if not all_metadata.has(folder_name):
		push_warning("SpriteFramesGenerator: no metadata entry for '%s', skipping." % folder_name)
		return
	var metadata: Dictionary = all_metadata[folder_name]

	# ── Enumerate PNGs in the character folder ────────────────────────────────
	var sprite_sheets_dir := DirAccess.open(char_path)
	if sprite_sheets_dir == null:
		push_warning("SpriteFramesGenerator: cannot open folder '%s', skipping." % char_path)
		return

	sprite_sheets_dir.list_dir_begin()
	var png := sprite_sheets_dir.get_next()
	while png != "":
		if not sprite_sheets_dir.current_is_dir() and png.get_extension().to_lower() == "png":
			var anim_name : String = png.get_basename()

			# ── Skip animations not in the filter (when filter is active) ─────
			if is_filter_active and anim_name not in animations_filter:
				png = sprite_sheets_dir.get_next()
				continue

			var png_path  : String = char_path.path_join(png)
			if not metadata.has(anim_name):
				push_warning(
					"SpriteFramesGenerator: '%s' not found in metadata for character '%s', skipping."
					% [anim_name, folder_name]
				)
				png = sprite_sheets_dir.get_next()
				continue
			var frame_count: int = int(metadata[anim_name]["frames"])
			if frame_count <= 0:
				push_warning("SpriteFramesGenerator: frame count is 0 for '%s/%s', skipping." % [folder_name, anim_name])
				png = sprite_sheets_dir.get_next()
				continue
			var strip_tex = load(png_path)
			if strip_tex == null:
				push_error("SpriteFramesGenerator: failed to load texture '%s'" % png_path)
				png = sprite_sheets_dir.get_next()
				continue
			var strip_w   : int = strip_tex.get_width()
			var strip_h   : int = strip_tex.get_height()
			var frame_w   : int = strip_w / frame_count

			# ── Replace animation if it already exists in the resource ────────
			if sprite_frames.has_animation(anim_name):
				sprite_frames.clear(anim_name)
			else:
				sprite_frames.add_animation(anim_name)
			sprite_frames.set_animation_speed(anim_name, DEFAULT_FPS)
			sprite_frames.set_animation_loop(anim_name, true)
			for i in frame_count:
				var atlas := AtlasTexture.new()
				atlas.atlas  = strip_tex
				atlas.region = Rect2(i * frame_w, 0, frame_w, strip_h)
				sprite_frames.add_frame(anim_name, atlas)

		png = sprite_sheets_dir.get_next()
	sprite_sheets_dir.list_dir_end()

	# ── Save .tres beside the character's spritesheets ────────────────────────
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(char_path)):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(char_path))
	var save_err := ResourceSaver.save(sprite_frames, tres_path)
	if save_err != OK:
		push_error("SpriteFramesGenerator: failed to save '%s' (error %d)" % [tres_path, save_err])
	else:
		print("SpriteFramesGenerator: saved '%s'" % tres_path)