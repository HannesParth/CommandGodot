class_name DisEntityController
extends Node
## Base class for [Entity] Controllers based on discrete commands.
##
## Extend this class for controller implementations. [br]
## This class would be [code]abstract[/code] if that were possible
## with GDScript.


## Reference to the [Entity] controlled.
var entity: Entity


func _init(e: Entity) -> void:
	self.entity = e


## Private function to crate a new [DisColorCommand] instance. [br]
## Makes sure the new color is different than the current one.
func _send_color_command() -> DisColorCommand:
	var newColor: Color = entity.colors.pick_random()
	while newColor == entity.get_sprite_color():
		newColor = entity.colors.pick_random()
	
	return DisColorCommand.new(entity, newColor)
