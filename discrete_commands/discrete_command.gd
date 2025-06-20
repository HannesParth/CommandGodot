class_name DiscreteCommand
extends RefCounted


var _entity: Entity


func _init(entity: Entity) -> void:
	_entity = entity


func execute() -> void:
	push_error("Command execute not implemented")


func reverse() -> void:
	push_error("Command reverse not implemented")
