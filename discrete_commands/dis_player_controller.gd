class_name DisPlayerController
extends DisEntityController
## Player input based implementation of the [DisEntityController].
##
## This implementation takes the players input through the [method Node._input]


func _input(event: InputEvent) -> void:
	if event.is_echo():
		return

	var command: DiscreteCommand
	if event.is_action_pressed("up"):
		command = DisMovementCommand.new(entity, Vector2i.UP)
	elif event.is_action_pressed("down"):
		command = DisMovementCommand.new(entity, Vector2i.DOWN)
	elif event.is_action_pressed("left"):
		command = DisMovementCommand.new(entity, Vector2i.LEFT)
	elif event.is_action_pressed("right"):
		command = DisMovementCommand.new(entity, Vector2i.RIGHT)
	elif event.is_action_pressed("color"):
		command = _send_color_command()
	
	if command == null:
		return
	
	# Execute command
	command.execute()
	
	# Add created command instance to list of executed commands
