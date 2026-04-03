# Datacenter.gd
# AutoLoad singleton
# Singleton API that holds and provides access to the current game states as Resource

extends Node


var map_resource: MapResource = null
var _character_resources: Array[CharacterResource] = []
var dialog_resource: DialogResource = null
var player_character_resource: PlayerCharacterResource = null # equivalent of LocalPlayer.as


## Emitted when the current map changes
signal map_changed(new_map: MapResource)


func _ready() -> void:
	print("[Datacenter] Ready")


## Replace map_resource with the new MapResource
## Flow: MapResource → stored as map_resource
func set_current_map_resource(map: MapResource) -> void:
	map_resource = map
	print("[Datacenter] Current map set to: %d" % map.map_id)
	map_changed.emit(map)


## Return current MapResource
## Flow: Returns current MapResource
func get_current_map() -> MapResource:
	return map_resource


## Return character id
func add_character_resource(p_character_resource: CharacterResource) -> int:
	p_character_resource.id = _character_resources.size()
	_character_resources.append(p_character_resource)
	return p_character_resource.id


func get_character_resource(character_id: int) -> CharacterResource:
	for character_resource in _character_resources:
		if character_resource.id == character_id:
			return character_resource
	push_error("[Datacenter] No character resource found for id %d" % character_id)
	return null