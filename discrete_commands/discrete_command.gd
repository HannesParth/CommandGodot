class_name DiscreteCommand
extends RefCounted
## Minimal base class for a discrete command.
##
## As a discrete command, an instance of an implementation of this 
## is initialized with the needed parameters, meaning one instance corresponds
## to one action.
##
## This class would be [code]abstract[/code] if that were possible
## with GDScript.
## To implement a command, extend this class and override the 
## [method DiscreteCommand.execute] and [method DiscreteCommand.reverse] methods.


var _entity: Entity


func _init(entity: Entity) -> void:
	_entity = entity


func execute() -> void:
	push_error("Command execute not implemented")


func reverse() -> void:
	push_error("Command reverse not implemented")
