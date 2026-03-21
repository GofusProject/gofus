## Data structure data model that holds every character data
##
## Has no real equivalent in Dofus.
## Extended by PlayableCharacter and NonPlayableCharacter
## Holded in Datacenter.CharacterResources

class_name CharacterResource
extends Resource

var id: int # need to be generated (can't use npc id as it could conflict with monster id, player id...)
var name: String
var cell_id: int
var map_id: int
## Path to SpriteFrames in assets folder.
var sprite_frames_id: int
## Initial facing direction (default 1).
var direction: int
## Color customization
var color1: int
var color2: int
var color3: int


func _init(p_name: String, p_cell_id: int, p_map_id: int, p_sprite_frames_id: int, p_direction: int, p_color1: int, p_color2: int, p_color3: int) -> void:
    name = p_name
    cell_id = p_cell_id
    map_id = p_map_id
    sprite_frames_id = p_sprite_frames_id
    direction = p_direction
    color1 = p_color1
    color2 = p_color2
    color3 = p_color3
