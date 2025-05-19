class_name PerColorCommand
extends PersistentCommand
## Implementation of the [PersistentCommand] to change the color of the 
## entities [Sprite2D].
##
## This class uses a simple pattern of implementing a [code]Params[/code]
## subclass which contains the properties needed for the entities 
## [method Entity.set_sprite_color] method. [br]
## This is for consistency: if other commands need multiple properties,
## they can use the same pattern.


func execute(entity: Entity, data: Object = null) -> void:
	if data is not Params:
		push_error("Color Command did not get the correct Params")
		return;
	
	entity.set_sprite_color((data as Params).picked_color)


class Params:
	var picked_color: Color
	
	func _init(col: Color) -> void:
		picked_color = col
