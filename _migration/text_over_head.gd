class_name TextOverHead
extends AbstractTextOverHead

# ─── References ───────────────────────────────────────────────────────────────

## The battlefield sprite this label is attached to.
## Must expose: `name` (String), `lp` (int), `pvp_gain` (int).
## Must emit the signal `lp_changed` when life points update.
var _o_sprite  # Typed as a generic Node; use a stricter type if you have one.

## Primary text label (damage number, status text, etc.)
var _txt_text  : Label

## Optional title label (shown above the main text when a title is provided)
var _txt_title : Label

# ─── Constructor ──────────────────────────────────────────────────────────────

## sText     – main body text
## s_file    – path prefix for the graphic asset (may be empty)
## n_color   – optional Color override for the main text (Color.TRANSPARENT = use format default)
## n_frame   – animation frame index for the graphic
## o_sprite  – the owning battlefield sprite node
## title     – Optional Dictionary { "text": String, "color": Color }
##             pass null / omit to show no title row.
func setup(
		s_text   : String,
		s_file   : String,
		n_color  : Color,
		n_frame  : int,
		o_sprite,
		title    = null
) -> void:
	_o_sprite = o_sprite
	_initialize_labels(title != null)
	_add_event_listeners()
	_draw_clip(s_text, s_file, n_color, n_frame,
			_o_sprite.pvp_gain if "pvp_gain" in _o_sprite else 0,
			title)


# ─── Initialization ───────────────────────────────────────────────────────────

func _initialize_labels(display_title: bool) -> void:
	super.initialize()   # Creates _mc_gfx and _mc_txt_background

	# Main text label — Flash depth 30
	_txt_text          = Label.new()
	_txt_text.name     = "_txt_text"
	_txt_text.position = Vector2(0.0, -3.0 + HEIGHT_SPACER)
	add_child(_txt_text)

	if display_title:
		_txt_title          = Label.new()
		_txt_title.name     = "_txt_title"
		_txt_title.position = Vector2(0.0, -3.0 + HEIGHT_SPACER)
		add_child(_txt_title)


# ─── Signal wiring ────────────────────────────────────────────────────────────

## Connect to the sprite's lp_changed signal (best-practice Godot equivalent
## of Flash's addEventListener).  Safe to call after _o_sprite is assigned.
func _add_event_listeners() -> void:
	if _o_sprite == null:
		return
	if _o_sprite.has_signal("lp_changed"):
		_o_sprite.lp_changed.connect(_on_lp_changed)
	else:
		push_warning("TextOverHead: o_sprite has no 'lp_changed' signal.")


# ─── Drawing ──────────────────────────────────────────────────────────────────

func _draw_clip(
		s_text  : String,
		s_file  : String,
		n_color : Color,
		n_frame : int,
		n_pvp_gain : int,
		title   = null
) -> void:
	var has_graphics := (s_file != "") and (n_frame > 0)

	_init_text_field(_txt_text, s_text, n_color, TEXT_FORMAT)

	var background_height : float
	var background_width  : float

	if title != null:
		_init_text_field(_txt_title, title.get("text", ""),
				title.get("color", Color.TRANSPARENT), TEXT_FORMAT2)

		# Position title below the main text row
		_txt_title.position.y = (_txt_text.position.y
				+ HEIGHT_SPACER
				+ _txt_text.get_combined_minimum_size().y)

		background_height = ceilf(
				_txt_text.get_combined_minimum_size().y
				+ _txt_title.get_combined_minimum_size().y
				+ HEIGHT_SPACER * 3.0)

		background_width = ceilf(
				maxf(_txt_text.get_combined_minimum_size().x,
					 _txt_title.get_combined_minimum_size().x)
				+ WIDTH_SPACER * 2.0)
	else:
		background_height = ceilf(
				_txt_text.get_combined_minimum_size().y + HEIGHT_SPACER * 2.0)
		background_width = ceilf(
				_txt_text.get_combined_minimum_size().x + WIDTH_SPACER * 2.0)

	draw_background(background_width, background_height, BACKGROUND_COLOR)

	if has_graphics:
		draw_gfx(s_file, n_frame)
		add_pvp_gfx_effect(n_pvp_gain, n_frame)


## Configure a Label to match Flash's initTextField().
func _init_text_field(
		label      : Label,
		s_text     : String,
		n_color    : Color,
		fmt        : Dictionary
) -> void:
	if label == null:
		return
	label.text             = s_text
	label.mouse_filter     = Control.MOUSE_FILTER_IGNORE   # non-selectable
	label.autowrap_mode    = TextServer.AUTOWRAP_OFF
	label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	apply_text_format(label, fmt, n_color)


# ─── Signal handler ───────────────────────────────────────────────────────────

## Replaces Flash's lpChanged(oEvent).
## Called whenever the sprite emits lp_changed.
func _on_lp_changed() -> void:
	var life_points_text := "%s (%d)" % [_o_sprite.name, _o_sprite.lp]
	_init_text_field(_txt_text, life_points_text, Color.TRANSPARENT, TEXT_FORMAT)

	# Recalculate and redraw background
	var background_height := ceilf(
			_txt_text.get_combined_minimum_size().y + HEIGHT_SPACER * 2.0)
	var background_width := ceilf(
			_txt_text.get_combined_minimum_size().x + WIDTH_SPACER * 2.0)

	draw_background(background_width, background_height, BACKGROUND_COLOR)
