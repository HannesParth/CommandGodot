class_name PerEntityController
extends Node
## Base class for [Entity] Controllers based on persistent commands.
##
## Extend this class for controller implementations. [br]
## This class would be [code]abstract[/code] if that were possible
## with GDScript.


## Reference to the [Entity] controlled.
var entity: Entity

## The instance of the Movement [PersistentCommand] used to move the [Entity]
var movement_command := PerMovementCommand.new()
## The instance of the Color Change [PersistentCommand] used to move the [Entity]
var color_command := PerColorCommand.new()

func _init(e: Entity) -> void:
	self.entity = e


## Private function to call the [PerColorCommand] execution. [br]
## Makes sure the new color is different than the current one.
func _send_color_command() -> void:
	var newColor: Color = entity.colors.pick_random()
	while newColor == entity.get_sprite_color():
		newColor = entity.colors.pick_random()
	
	var params = PerColorCommand.Params.new(newColor)
	color_command.execute(entity, params)
