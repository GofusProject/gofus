class_name SpriteMetadataResource
extends Resource


var animation_name: String = ""
var frame_count: int
var offset: Vector2

func _init(sprite_metadata: Dictionary) -> void:
    frame_count = int(sprite_metadata.get("frames", 0))
    offset = Vector2(
        sprite_metadata.get("horizontal", 0),
        sprite_metadata.get("vertical", 0)
    )