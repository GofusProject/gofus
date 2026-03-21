class_name AbstractTextOverHead
extends Node2D

# ─── Constants ────────────────────────────────────────────────────────────────

const BACKGROUND_ALPHA := 0.70        # Flash used 0-100, Godot uses 0.0-1.0
const BACKGROUND_COLOR := Color(0, 0, 0, 0.70)

const CORNER_RADIUS := 0.0
const WIDTH_SPACER   := 4.0
const HEIGHT_SPACER  := 4.0

# Equivalent TextFormat definitions (Flash → Godot theme/font overrides)
# These are used as hints when configuring Label nodes.
const FONT_FAMILY   := "Verdana"      # Swap for a .ttf in res:// if needed

# TEXT_FORMAT  → bold, size 10, white, center
const TEXT_FORMAT := {
	"size":   10,
	"bold":   true,
	"color":  Color.WHITE,
	"align":  HORIZONTAL_ALIGNMENT_CENTER,
}

# TEXT_FORMAT2 → normal, size 9, white, center
const TEXT_FORMAT2 := {
	"size":   9,
	"bold":   false,
	"color":  Color.WHITE,
	"align":  HORIZONTAL_ALIGNMENT_CENTER,
}

# TEXT_SMALL_FORMAT → normal, size 10, white, left
const TEXT_SMALL_FORMAT := {
	"size":   10,
	"bold":   false,
	"color":  Color.WHITE,
	"align":  HORIZONTAL_ALIGNMENT_LEFT,
}

# TEXT_SMALL_FORMAT2 → normal, size 9, white, left
const TEXT_SMALL_FORMAT2 := {
	"size":   9,
	"bold":   false,
	"color":  Color.WHITE,
	"align":  HORIZONTAL_ALIGNMENT_LEFT,
}

# ─── Child nodes (created in initialize()) ────────────────────────────────────

var _mc_txt_background : ColorRect   # Replaces _mcTxtBackground (drawn round-rect)
var _mc_gfx            : Node2D      # Replaces _mcGfx (holds the loaded graphic)

# ─── Lifecycle ────────────────────────────────────────────────────────────────

func _init() -> void:
	pass

## Call from the subclass constructor after super.initialize().
func initialize() -> void:
	# _mcGfx at depth 10  →  added first so it renders below text background
	_mc_gfx = Node2D.new()
	_mc_gfx.name = "_mc_gfx"
	add_child(_mc_gfx)

	# _mcTxtBackground at depth 20
	_mc_txt_background = ColorRect.new()
	_mc_txt_background.name = "_mc_txt_background"
	add_child(_mc_txt_background)

# ─── Size helpers (mirroring Flash's width/height getters) ────────────────────

func get_width() -> int:
	return ceili(size.x) if has_method("size") else 0

func get_height() -> int:
	return ceili(size.y) if has_method("size") else 0

# ─── Drawing ──────────────────────────────────────────────────────────────────

## Draws a rounded rectangle background.
## Flash centered horizontally ( -nWidth/2, 0 ) — we replicate that with an offset.
func draw_background(n_width: float, n_height: float, color: Color) -> void:
	_mc_txt_background.color          = color
	_mc_txt_background.size           = Vector2(n_width, n_height)
	# Horizontally center around the node origin, matching Flash's (-nWidth/2, 0)
	_mc_txt_background.position       = Vector2(-n_width / 2.0, 0.0)

	# Godot's ColorRect has no built-in corner radius; for rounded corners swap
	# ColorRect for a NinePatchRect or draw via CanvasItem.draw_* in _draw().
	# CORNER_RADIUS is available here if you implement that later.


## Loads a sprite/animation frame into _mc_gfx.
## Replaces attachClassMovie + loadSWF — adapt path convention to your project.
func draw_gfx(s_file: String, n_frame: int) -> void:
	# Clear previous children
	for child in _mc_gfx.get_children():
		child.queue_free()

	var texture_path := "res://%s/%d.png" % [s_file, n_frame]
	var tex : Texture2D = load(texture_path)
	if tex == null:
		push_warning("AbstractTextOverHead: could not load texture at %s" % texture_path)
		return

	var sprite := Sprite2D.new()
	sprite.texture = tex
	_mc_gfx.add_child(sprite)


## Applies a visual effect on _mc_gfx depending on PvP gain value.
##   -1 → dim (50 % alpha)
##    1 → coloured glow  (colour chosen by frame tier)
func add_pvp_gfx_effect(n_pvp_gain: int, n_frame: int) -> void:
	match n_pvp_gain:
		-1:
			# Flash ColorMatrixFilter at 50 % → modulate alpha
			_mc_gfx.modulate = Color(1.0, 1.0, 1.0, 0.5)

		1:
			# Glow colour depends on frame tier (every 10 frames = 1 tier)
			var tier := (n_frame - 1) / 10
			var glow_color : Color
			match tier:
				0: glow_color = Color(0x00AAFFFF)   # 11201279 ≈ cyan-blue
				1: glow_color = Color(0xCC0000FF)   # 13369344 ≈ dark red
				_: glow_color = Color.BLACK

			# Godot doesn't have a built-in GlowFilter on nodes; the cleanest
			# equivalent is a ShaderMaterial.  We apply a simple modulate tint
			# as a lightweight fallback — replace with a glow shader if needed.
			_mc_gfx.modulate = glow_color.lerp(Color.WHITE, 0.5)
			# TODO: replace with a proper GlowFilter shader for a pixel-perfect port.

		_:
			_mc_gfx.modulate = Color.WHITE  # reset


## Applies text format constants to a Label node.
func apply_text_format(label: Label, fmt: Dictionary, color_override: Color = Color.TRANSPARENT) -> void:
	label.horizontal_alignment = fmt.get("align", HORIZONTAL_ALIGNMENT_LEFT)
	label.add_theme_font_size_override("font_size", fmt.get("size", 10))

	var col : Color = fmt.get("color", Color.WHITE)
	if color_override != Color.TRANSPARENT:
		col = color_override
	label.add_theme_color_override("font_color", col)

	# Bold: load a bold variant of your font if available, otherwise ignored.
	# label.add_theme_font_override("font", preload("res://fonts/Verdana-Bold.ttf"))
