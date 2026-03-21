class_name PlayablePlayerResource
extends CharacterResource



func _init(p_data: Dictionary) -> void:
    super._init(p_data["name"], p_data["cell"], p_data["map"], p_data["gfx"], CharacterSpriteHandler.Direction.SOUTH_EAST, p_data["color1"], p_data["color2"], p_data["color3"], p_data["size"])

