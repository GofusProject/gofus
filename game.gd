extends Node


var is_debug_mode: bool = false

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
	actions.create_map_and_characters(p_map_id, player_id)
		
	
