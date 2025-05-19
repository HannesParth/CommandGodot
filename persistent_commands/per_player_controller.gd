class_name PerPlayerController
extends PerEntityController
## Player input based implementation of the [PerEntityController].
##
## This implementation takes the players input through the [method Node._input]
## method trigger the execution of the [PerMovementCommand] and [PerColorCommand].


func _input(event: InputEvent) -> void:
	if event.is_echo():
		return

	var params: PerMovementCommand.Params
	
	if event.is_action_pressed("up"):
		params = PerMovementCommand.Params.new(Vector2i.UP)
	elif event.is_action_pressed("down"):
		params = PerMovementCommand.Params.new(Vector2i.DOWN)
	elif event.is_action_pressed("left"):
		params = PerMovementCommand.Params.new(Vector2i.LEFT)
	elif event.is_action_pressed("right"):
		params = PerMovementCommand.Params.new(Vector2i.RIGHT)
	elif event.is_action_pressed("color"):
		_send_color_command()
	
	if params != null:
		movement_command.execute(entity, params)
