class_name PerColorCommand
extends PersistentCommand

class Params:
	var picked_color: Color
	
	func _init(col: Color) -> void:
		picked_color = col

func execute(entity: Entity, data: Object = null) -> void:
	if data is not Params:
		push_error("Color Command did not get the correct Params")
		return;
	
	entity.set_sprite_color((data as Params).picked_color)
