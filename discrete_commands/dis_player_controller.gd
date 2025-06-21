class_name DisPlayerController
extends DisEntityController
## Player input based implementation of the [DisEntityController].
##
## This implementation takes the players input through the [method Node._input]
## method to create [DiscreteCommand] instances, which are then executed and 
## added to the Undo Stack.


func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if !entity.enable:
		return

	var command: DiscreteCommand
	var direction = Vector2i(-2, -2)
	if event.is_action_pressed("up"):
		direction = Vector2i.UP
	elif event.is_action_pressed("down"):
		direction = Vector2i.DOWN
	elif event.is_action_pressed("left"):
		direction = Vector2i.LEFT
	elif event.is_action_pressed("right"):
		direction = Vector2i.RIGHT
	elif event.is_action_pressed("color"):
		command = _send_color_command()
	
	# If the direction has been set and the entity can move in that 
	# direction, create the movement command.
	if direction != Vector2i(-2, -2):
		if !entity.can_move_in_direction(direction):
			return
		else:
			command = DisMovementCommand.new(entity, direction)
	
	if command == null:
		return
	
	# Execute command
	command.execute()
	
	# Add created command instance to list of executed commands
	UndoManager.add_executed(command)
