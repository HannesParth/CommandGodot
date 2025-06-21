class_name DisColorCommand
extends DiscreteCommand
## Implementation of the [DiscreteCommand] to change the color of the entities
## [Sprite2D]
##
## It needs properties for both the color picked by the [Entity] and the color
## it had before the change to perform the reverse change.


var _picked_color: Color
var _previous_color: Color


func _init(entity: Entity, color: Color) -> void:
	super(entity)
	_picked_color = color


func execute() -> void:
	_previous_color = _entity.get_sprite_color()
	_entity.set_sprite_color(_picked_color)


func reverse() -> void:
	_entity.set_sprite_color(_previous_color)
