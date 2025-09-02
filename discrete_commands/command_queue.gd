extends Node
## Global CommandQueue
##
## A minimalistic implementation of a command caller to demonstrate
## the decoupling of command creation and execution for discrete commands.


var _queue: Array[DiscreteCommand] = []


func _physics_process(_delta: float) -> void:
	process_queue()


func append(command: DiscreteCommand) -> void:
	_queue.append(command)


## Executes all commands in the queue synchonously.
func process_queue() -> void:
	for cmd in _queue:
		cmd.execute()
		UndoManager.add_executed(cmd)
	_queue.clear()
