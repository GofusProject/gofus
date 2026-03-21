@tool   # Remove this line if you don't need live preview in the editor
class_name TextOverHead
extends Node2D

# ─── Constants (ported from AbstractTextOverHead) ─────────────────────────────

const BACKGROUND_ALPHA  := 0.70
const BACKGROUND_COLOR  := Color(0.0, 0.0, 0.0, 0.70)
const CORNER_RADIUS     := 3.0
const WIDTH_SPACER      := 4.0
const HEIGHT_SPACER     := 4.0

# ─── Exported properties (editable in the Inspector) ──────────────────────────

## Main text displayed on the overlay.
@export var main_text  : String = "Sample Text" :
	set(v): main_text = v ; _refresh()

## Optional title shown below the main text. Leave empty to hide.
@export var title_text : String = "" :
	set(v): title_text = v ; _refresh()

## Override colour for main text. Transparent = use white default.
@export var main_color  : Color = Color.TRANSPARENT :
	set(v): main_color = v ; _refresh()

## Override colour for title text. Transparent = use white default.
@export var title_color : Color = Color.TRANSPARENT :
	set(v): title_color = v ; _refresh()

# ─── Sprite reference (set at runtime via setup()) ────────────────────────────

## The battlefield sprite this label tracks.
## Must expose: `name` (String), `lp` (int), `pvp_gain` (int).
## Must emit: signal `lp_changed`.
var _o_sprite : Node = null

# ─── Internal node references (resolved in _ready) ────────────────────────────

@onready var _mc_txt_background : Panel   = $McTxtBackground
@onready var _mc_labels         : Node2D  = $McLabels
@onready var _txt_text          : Label   = $McLabels/TxtText
@onready var _txt_title         : Label   = $McLabels/TxtTitle
@onready var _mc_gfx            : Node2D  = $McGfx

# ─── Lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	_refresh()


# ─── Public API ───────────────────────────────────────────────────────────────

## Full initialisation — mirrors the original ActionScript constructor.
## Call this after add_child() to wire everything up.
##
##   s_text    – main body text
##   s_file    – asset path prefix for the graphic (pass "" for none)
##   n_color   – Color for main text  (Color.TRANSPARENT = default white)
##   n_frame   – frame / index for the graphic asset  (0 = none)
##   o_sprite  – owning battlefield sprite node
##   title     – Optional { "text": String, "color": Color } dict, or null
func setup(
		s_text   : String,
		s_file   : String,
		n_color  : Color,
		n_frame  : int,
		o_sprite : Node,
		title               = null
) -> void:
	_o_sprite  = o_sprite
	main_text  = s_text
	main_color = n_color

	if title != null:
		title_text  = title.get("text",  "")
		title_color = title.get("color", Color.TRANSPARENT)
	else:
		title_text = ""

	_connect_sprite()


# ─── Sprite signal ────────────────────────────────────────────────────────────

func _connect_sprite() -> void:
	if _o_sprite == null:
		return
	if _o_sprite.has_signal("lp_changed"):
		if not _o_sprite.lp_changed.is_connected(_on_lp_changed):
			_o_sprite.lp_changed.connect(_on_lp_changed)
	else:
		push_warning("TextOverHead: o_sprite has no 'lp_changed' signal.")


## Emitted by the sprite when LP changes — updates text and redraws background.
func _on_lp_changed() -> void:
	main_text = "%s (%d)" % [_o_sprite.name, _o_sprite.lp]


# ─── Layout & drawing ─────────────────────────────────────────────────────────

## Central layout function: sizes labels → resizes background → centres everything.
func _refresh() -> void:
	# _ready hasn't fired yet (e.g. @tool in editor before scene is ready)
	if not is_node_ready():
		return

	# ── Labels ────────────────────────────────────────────────────────────────
	_apply_label(_txt_text,  main_text,  main_color,  10, true)

	var show_title := title_text != ""
	_txt_title.visible = show_title

	if show_title:
		_apply_label(_txt_title, title_text, title_color, 9, false)

	# Force a layout pass so get_combined_minimum_size() is accurate
	_txt_text.reset_size()
	if show_title:
		_txt_title.reset_size()

	# ── Measure ───────────────────────────────────────────────────────────────
	var text_size  : Vector2 = _txt_text.get_combined_minimum_size()
	var title_size : Vector2 = Vector2.ZERO
	if show_title:
		title_size = _txt_title.get_combined_minimum_size()

	var bg_width  : float
	var bg_height : float

	if show_title:
		bg_width  = ceilf(maxf(text_size.x, title_size.x) + WIDTH_SPACER  * 2.0)
		bg_height = ceilf(text_size.y + title_size.y      + HEIGHT_SPACER * 3.0)
	else:
		bg_width  = ceilf(text_size.x + WIDTH_SPACER  * 2.0)
		bg_height = ceilf(text_size.y + HEIGHT_SPACER * 2.0)

	# ── Background ────────────────────────────────────────────────────────────
	# Horizontally centred around the node origin, matching Flash's (-nWidth/2, 0)
	_mc_txt_background.size     = Vector2(bg_width, bg_height)
	_mc_txt_background.position = Vector2(-bg_width / 2.0, 0.0)

	# ── Label positions inside McLabels ───────────────────────────────────────
	# Main text — padded inside the background, horizontally centred
	_txt_text.size              = Vector2(bg_width - WIDTH_SPACER * 2.0, text_size.y)
	_txt_text.position          = Vector2(
			-bg_width / 2.0 + WIDTH_SPACER,
			HEIGHT_SPACER + (-3.0 + HEIGHT_SPACER)   # mirrors Flash's _y = -3 + HEIGHT_SPACER
	)

	if show_title:
		_txt_title.size     = Vector2(bg_width - WIDTH_SPACER * 2.0, title_size.y)
		_txt_title.position = Vector2(
				-bg_width / 2.0 + WIDTH_SPACER,
				_txt_text.position.y + text_size.y + HEIGHT_SPACER
		)


## Configure a Label node's visual properties.
func _apply_label(label: Label, text: String,
		color     : Color,
		font_size : int,
		bold      : bool        # reserved: swap in a bold font override if available
) -> void:
	label.text                 = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter         = Control.MOUSE_FILTER_IGNORE
	label.autowrap_mode        = TextServer.AUTOWRAP_OFF
	label.add_theme_font_size_override("font_size", font_size)

	var col := Color.WHITE if color == Color.TRANSPARENT else color
	label.add_theme_color_override("font_color", col)

	# Bold hint — uncomment and point to your font files if needed:
	# if bold:
	#     label.add_theme_font_override("font", preload("res://fonts/Verdana-Bold.ttf"))