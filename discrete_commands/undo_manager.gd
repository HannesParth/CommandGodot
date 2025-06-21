extends Node
## The Autoload for a simple Undo System.
##
## This class contains a stack of [DiscreteCommand] with a set max length.
## It has methods to add commands to the stack, undo and redo them.
## When adding a command would exceed the max stack length, 
## the oldest command is discarded.
## When adding a command while not at the front of the stack, 
## everything in front of that new command is discarded.


const MAX_STACK_LENGTH: int = 30

## Signal emitted when a new command was added. Gives the new size
## of the stack and the new current index, which should be size -1
signal command_added(new_stack_size: int, new_current_index: int)

## Signal emitted when undo() was called.
## Gives the new current index.
signal command_undone(new_current_index: int)

## Signal emitted when redo() was called.
## Gives the new current index.
signal command_redone(new_current_index: int)


## Current size of the stack, made to be accessible from outside.
var stack_size: int:
	get:
		return _executed_commands.size()

var _current_index: int
var _executed_commands: Array[DiscreteCommand] = []


## Adds a [DiscreteCommand] instance to the Undo Stack. 
## Discards the oldest command in the stack if adding the new one would
## exceed the max stack length.
## Discards everything in front of the added command if the current_index
## is not at the front of the stack.
func add_executed(command: DiscreteCommand) -> void:
	# If we are not at the front of the stack when a new command comes in,
	# discard everything after the current position
	if _executed_commands.size() > 0 && _current_index != _executed_commands.size() - 1:
		_executed_commands.resize(_current_index + 1)
	
	if _executed_commands.size() + 1 > MAX_STACK_LENGTH:
		_executed_commands.pop_front()
	
	_executed_commands.append(command)
	_current_index = _executed_commands.size() - 1
	
	command_added.emit(_executed_commands.size(), _current_index)


## Calls [method DiscreteCommand.reverse] for the command at the current_index of 
## the Undo Stack and lowers it by 1
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


## Calls [method DiscreteCommand.execute] for the command at the
## current_index + 1
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
