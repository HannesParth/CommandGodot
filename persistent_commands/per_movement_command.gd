class_name PerMovementCommand
extends PersistentCommand

class Params:
	var direction: Vector2i
	
	func _init(dir: Vector2i) -> void:
		direction = dir

func execute(entity: Entity, data: Object = null) -> void:
	if data is not Params:
		push_error("Movement Command did not get the correct Params")
		return;
	
	entity.move((data as Params).direction)
