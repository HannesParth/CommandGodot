extends Node
## A simple Autoload to manage the activation state of all [Entity] in the scene.
##
## Was bastardized a bit to dynamically manage the activation of the Undo Menu,
## since that menu is the only thing that uses this class.


var is_paused: bool = false

var _entites: Dictionary[Entity, bool] = {}


func _ready() -> void:
	_activate_undo_menu_if_used()


func _activate_undo_menu_if_used() -> void:
	if _entites.keys().any(_entity_uses_discrete_commands):
		var undo_menu = get_node("/root/Map/UndoMenu")
		
		undo_menu.show()


func _entity_uses_discrete_commands(entity: Entity) -> bool:
	return entity.controller_type == Entity.ControllerType.DIS_AI \
		|| entity.controller_type == Entity.ControllerType.DIS_PLAYER


func register(entity: Entity) -> void:
	_entites.set(entity, entity.enable)


func pause_execution() -> void:
	for entity in _entites:
		entity.enable = false
	
	is_paused = true


func resume_execution() -> void:
	for entity in _entites:
		entity.enable = _entites[entity]
	
	is_paused = false
