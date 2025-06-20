class_name PersistentCommand
extends RefCounted
## Minimal base class for a persistent command.
##
## As a persistent command, it does not save the parameters it was called
## with. Instead, single instances of these types of command are called
## repeatedly with the parameters given each time.
##
## This class would be [code]abstract[/code] if that were possible
## with GDScript.
## To implement a command, extend this class and override the 
## [method PersistentCommand.execute] method.


@warning_ignore("unused_parameter")
func execute(entity: Entity, data: Object = null) -> void:
	push_error("Command execute not implemented")
