class_name PerMovementCommand
extends PersistentCommand
## Implementation of the [PersistentCommand] to call [Entity] movement.
##
## This class uses a simple pattern of implementing a [code]Params[/code]
## subclass which contains the properties needed for the entities 
## [method Entity.move] method. [br]
## This is for consistency: if other commands need multiple properties,
## they can use the same pattern.


func execute(entity: Entity, data: Object = null) -> void:
	if data is not Params:
		push_error("Movement Command did not get the correct Params")
		return;
	
	entity.move((data as Params).direction)


class Params:
	var direction: Vector2i
	
	func _init(dir: Vector2i) -> void:
		direction = dir
