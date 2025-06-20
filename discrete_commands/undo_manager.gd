extends Node


signal command_added(new_stack_size: int, new_current_index: int)
signal command_undone(new_current_index: int)
signal command_redone(new_current_index: int)


const STACK_LENGTH: int = 30

var stack_size: int:
	get:
		return _executed_commands.size()

var _current_index: int
var _executed_commands: Array[DiscreteCommand] = []


func add_executed(command: DiscreteCommand) -> void:
	# If we are not at the top of the stack when a new command comes in,
	# discard everything after the current position
	if _executed_commands.size() > 0 && _current_index != _executed_commands.size() - 1:
		_executed_commands.resize(_current_index + 1)
	
	if _executed_commands.size() + 1 > STACK_LENGTH:
		_executed_commands.pop_front()
	
	_executed_commands.append(command)
	_current_index = _executed_commands.size() - 1
	
	command_added.emit(_executed_commands.size(), _current_index)


func undo() -> int:
	if _executed_commands.size() == 0:
		print("UndoManager: no commands to undo, stack empty")
		return _current_index
	
	if _current_index == -1:
		print("UndoManager: reached end of undo stack")
		return _current_index
	
	if _current_index < -1 || _current_index >= _executed_commands.size():
		push_error("Command stack index out of bounds. Index: " + str(_current_index)\
			+ "\nStack size: " + str(_executed_commands.size()))
		return _current_index
	
	var to_undo: DiscreteCommand = _executed_commands[_current_index]
	to_undo.reverse()
	_current_index -= 1
	
	command_undone.emit(_current_index)
	return _current_index


func redo() -> int:
	if _executed_commands.size() == 0:
		print("UndoManager: no commands to redo, stack empty")
		return _current_index
	
	if _current_index == _executed_commands.size() - 1:
		print("UndoManager: reached tip of redo stack")
		return _current_index
	
	if _current_index < -1 || _current_index >= _executed_commands.size():
		push_error("Command stack index out of bounds. Index: " + str(_current_index)\
			+ "\nStack size: " + str(_executed_commands.size()))
		return _current_index
	
	var to_redo: DiscreteCommand = _executed_commands[_current_index + 1] as DiscreteCommand
	to_redo.execute()
	_current_index += 1
	
	command_redone.emit(_current_index)
	return _current_index
