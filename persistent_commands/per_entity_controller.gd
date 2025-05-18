class_name PerEntityController
extends Node


var entity: Entity

var movement_command := PerMovementCommand.new()
var color_command := PerColorCommand.new()

func _init(e: Entity) -> void:
	self.entity = e

func _send_color_command() -> void:
	var newColor: Color = entity.colors.pick_random()
	while newColor == entity.get_sprite_color():
		newColor = entity.colors.pick_random()
	
	var params = PerColorCommand.Params.new(newColor)
	color_command.execute(entity, params)
