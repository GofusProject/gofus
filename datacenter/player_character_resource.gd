## Character.as equivalent
## Use player data from player table database to init it self
## Can be weird to have player related stuff here, but entries from player table are extremely related to characters 


class_name PlayerCharacterResource
extends PlayableCharacterResource


# Later: Guild, title, Aura...



func _init(p_data: Dictionary) -> void:
	super._init(
		p_data["name"],
		int(p_data["cell"]), 
		int(p_data["map"]), 
		int(p_data["gfx"]),
		CharacterSpriteHandler.Orientation.SOUTH_EAST,
		int(p_data["color1"]),
		int(p_data["color2"]),
		int(p_data["color3"]),
		int(p_data["size"])
		)