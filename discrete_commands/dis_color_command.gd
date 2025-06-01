class_name DisColorCommand
extends DiscreteCommand


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
