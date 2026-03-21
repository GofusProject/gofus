class_name PlayablePlayerResource
extends CharacterResource



func _init(p_data: Dictionary) -> void:
	super._init(
		p_data["name"],
		int(p_data["cell"]), 
		int(p_data["map"]), 
		int(p_data["gfx"]),
		CharacterSpriteHandler.Direction.SOUTH_EAST,
		int(p_data["color1"]),
		int(p_data["color2"]),
		int(p_data["color3"]),
		int(p_data["size"])
		)
