class_name DisMovementCommand
extends DiscreteCommand
## Implementation of the [DiscreteCommand] to call [Entity] movement.


var _direction: Vector2i


func _init(entity: Entity, direction: Vector2i) -> void:
	super(entity)
	_direction = direction


func execute() -> void:
	_entity.move(_direction)


func reverse() -> void:
	_entity.move(-_direction)
