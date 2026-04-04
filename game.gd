extends Node


var is_debug_mode: bool = true

var map_id: int = 10302
var player_id: int = 1
var actions: Actions

var player: Player

# Modules
var database: Database
var datacenter: Datacenter
var gofus_translator: GofusTranslator
var asset_loader: AssetLoader
var battlefield: Battlefield
const BATTLEFIELD_SCENE: PackedScene = preload("res://graphics/battlefield/scenes/Battlefield.tscn")
var ui: UI
const UI_SCENE: PackedScene = preload("res://graphics/ui/scenes/ui.tscn")

# Manager
var map_manager: MapManager
var characters_manager: CharactersManager
var dialog_manager: DialogManager



func _ready() -> void:

	# Modules init
	database = Database.new()
	datacenter = Datacenter.new()
	gofus_translator = GofusTranslator.new()
	asset_loader = AssetLoader.new()
	battlefield = BATTLEFIELD_SCENE.instantiate()
	ui = UI_SCENE.instantiate()

	add_child(database)
	add_child(datacenter)
	add_child(gofus_translator)
	add_child(asset_loader)
	add_child(battlefield)
	add_child(ui)

	database.name = "Database"
	datacenter.name = "Datacenter"
	gofus_translator.name = "GofusTranslator"
	asset_loader.name = "AssetLoader"
	battlefield.name = "Battlefield"
	ui.name = "UI"

	# Managers init
	map_manager = MapManager.new()
	characters_manager = CharactersManager.new()
	dialog_manager = DialogManager.new()

	add_child(map_manager)
	add_child(characters_manager)
	add_child(dialog_manager)

	map_manager.name = "MapManager"
	characters_manager.name = "CharactersManager"
	dialog_manager.name = "DialogManager"

	map_manager.initialize(database, datacenter, gofus_translator, asset_loader, battlefield, ui)
	characters_manager.initialize(database, datacenter, gofus_translator, asset_loader, battlefield, ui)
	dialog_manager.initialize(database, datacenter, gofus_translator, asset_loader, battlefield, ui)

	map_manager.setup_signals(characters_manager)
	characters_manager.setup_signals()

	# Actions
	actions = Actions.new()
	actions.initialize(map_manager, characters_manager, dialog_manager)

	# Player
	player = Player.new()
	player.actions = actions
	player.setup_signals()

	map_manager.scripted_cell_triggered.connect(func(action_resource: ActionResource): execute_action(action_resource))
	create_map(map_id)


# func _input(event: InputEvent) -> void:
# 	if event is InputEventKey:
# 		if event.keycode == KEY_F12:
# 			get_tree().quit()
	
# 	if event.is_action_pressed("ui_right"):
# 			map_id += 1
# 			create_map(map_id)

# 	if event.is_action_pressed("ui_left"):
# 			map_id -= 1
# 			create_map(map_id)



func execute_action(action_resource: ActionResource) -> void:
	# if action.condition and not action.condition.is_met(character):
	# 	return

	match action_resource.action_id:
		ActionResource.ActionId.TELEPORTATION:
			actions.teleport(datacenter.player_character_resource.id, action_resource.param_1, action_resource.param_2)


func create_map(p_map_id: int):

	var is_map_created = map_manager.create_map(p_map_id)
	if not is_map_created:
		push_error("[Game] Map changed failed")
		return

	# Player creation 
	var player_character_id: int = characters_manager.create_player_character(player_id)
	if player_character_id != -1:
		var player_character_cell_id = characters_manager.get_character_cell_id(player_character_id)
		var player_world_position = map_manager.get_cell_world_position_from_cell_id(player_character_cell_id)
		characters_manager.teleport_character(player_character_id, player_world_position, player_character_cell_id)
		if is_debug_mode: print("[Game] Player character created with id %d and teleported to cell id %d (world position: %s)" % [player_character_id, player_character_cell_id, player_world_position])
	else:
		push_error("[Game] Player character creation failed")


	# Npcs creation
	var npc_ids: Array[int] = map_manager.get_current_map_npc_ids()

	for npc_id in npc_ids:
		if is_debug_mode: print("[Game] Create NPC character with npc id:", npc_id)
		var npc_character_id: int = characters_manager.create_npc(npc_id)
		if npc_character_id == -1:
			continue
		
		var npc_character_cell_id = characters_manager.get_character_cell_id(npc_character_id)
		var npc_world_position = map_manager.get_cell_world_position_from_cell_id(npc_character_cell_id)
		characters_manager.teleport_character(npc_character_id, npc_world_position, npc_character_cell_id)
		
	
