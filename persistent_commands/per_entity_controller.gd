class_name PerEntityController
extends Node


var entity: Entity

var movement_command := PerMovementCommand.new()

func _init(e: Entity) -> void:
	self.entity = e
