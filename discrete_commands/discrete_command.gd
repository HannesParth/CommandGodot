class_name DiscreteCommand
extends RefCounted


var _entity: Entity


func _init(entity: Entity) -> void:
	_entity = entity


func execute() -> void:
	pass


func reverse() -> void:
	pass
