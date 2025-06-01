extends Node


const STACK_LENGTH: int = 30

var _current_index: int

@onready var _executed_commands: Array[DiscreteCommand] = []


func add_executed(command: DiscreteCommand) -> void:
	# If we are not at the top of the stack when a new command comes in,
	# discard everything after the current position
	if _current_index != _executed_commands.size() - 1:
		_executed_commands.resize(_current_index + 1)
	
	if _executed_commands.size() + 1 > STACK_LENGTH:
		_executed_commands.pop_front()
	
	_executed_commands.append(command)
	_current_index = _executed_commands.size() - 1


func undo() -> void:
	if _executed_commands.size() == 0:
		print("UndoManager: no commands to undo, stack empty")
		return
	
	if _current_index == 0:
		print("UndoManager: reached end of undo stack")
		return
	
	if _current_index < 0 || _current_index >= _executed_commands.size():
		push_error("Command stack index out of bounds. Index: " + str(_current_index)\
			+ "\nStack size: " + str(_executed_commands.size()))
		return
	
	var to_undo: DiscreteCommand = _executed_commands[_current_index]
	to_undo.reverse()
	_current_index -= 1


func redo() -> void:
	if _executed_commands.size() == 0:
		print("UndoManager: no commands to redo, stack empty")
		return
	
	if _current_index == _executed_commands.size() - 1:
		print("UndoManager: reached tip of redo stack")
		return
	
	if _current_index < 0 || _current_index >= _executed_commands.size():
		push_error("Command stack index out of bounds. Index: " + str(_current_index)\
			+ "\nStack size: " + str(_executed_commands.size()))
		return
	
	var to_redo: DiscreteCommand = _executed_commands[_current_index]
	to_redo.execute()
	_current_index += 1
