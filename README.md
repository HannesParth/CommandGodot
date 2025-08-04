# CommandGodot
A clean example implementation of the Command Pattern in Godot 4.4 with added visualizations.

## Usage and Goal
This is meant to be a written tutorial explaining the command pattern for [object-oriented programming](https://en.wikipedia.org/wiki/Object-oriented_programming). 
The main priorties are understanding the purpose, core concept and functionality of the pattern.

The project has been implemented trying to follow the [SOLID](https://en.wikipedia.org/wiki/SOLID) principles of programming and the [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html).


## What is the Command Pattern?
Robert Nystrom's tagline breaks it down to the most essential:
> A command is a reified method call.

He sensibly includes an explanation for 'reify', which boils down to "make something into a thing".

I want to make this understanding even more direct (especially for people familiar with object-oriented programming) with the tagline:
> A command is an object wrapping a method.

To demonstrate, we have a method:
```gdscript
func greet() -> void:
    print("Hello World!")
```
We *could* just shove that into a class class and call it a day:
```gdscript
class_name GreetCommand

func greet() -> void:
    print("Hello World!")
```
But now we only have one object that can do one specific thing which we always have to specifically reference.

Now, while GDScript does not have abstract classes and methods *yet*, it does have inheritence:
```gdscript
class_name Command

func execute() -> void:
    pass
```
```gdscript
class_name GreetCommand
extends Command

func execute() -> void:
    print("Hello World!")
```

> 💡 **Note**: In GDScript, if inheritance is not explicitly defined (no "extends" was used), the class will implicitly extend `RefCounted` (see the [docs](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#inheritance)).

### What is it used for?
Being able to treat a method as an object enables many methodologies, including **Undo/Redo** Functionality, **Command Queues** and **Scheduling**, and **Macro Commands** (Batch Operations).

Of the SOLID principles, the command pattern innately follows or encourages the Single Responsiblity, Open-closed, and Liskov Substitution principles.

General benefits are:
- **Decoupling**: The object invoking the command doesn't need to know anything about the receiver or how the action is performed.
- **Extensibility**: New commands can be added without changing existing code.

The most direct drawbacks are:
- **Increased code complexity**: Every command operation becomes a new object you have to organize and manage.
- **Potentially more difficult debugging**: Increased decoupling and abstraction can make debugging harder.
- **State Management**: If commands can be undone, storing and restoring their state increases complexity and can be error-prone.

Further examples of the patterns usage can be found on its [Wikipedia](https://en.wikipedia.org/wiki/Command_pattern#Uses) page.


## Implementing Commands
### Disclaimer
This project uses my own terms of *persistent* and *discrete* commands. 

While this distinction is often used in explanations of the command pattern (see [Wikipedia](https://en.wikipedia.org/wiki/Command_pattern#Terminology) or [Game Programming Patterns](https://gameprogrammingpatterns.com/command.html#undo-and-redo)), a cursory search has not found any cases of this being explicitly named.

### Project Setup
This project aims to demonstrate the pattern by implementing two commands of each type (a `Movement` and a `Color` command), which both affect instances of an `Entity` that moves on a 2D grid. It also implements a simple undo/redo system, which is visualized to decrease cognitive load.

<img src="./docs/images/overview.png" alt="Overview of the main scene" style="max-width: 500px; height: auto;" />

To demonstrate decoupling with the command pattern, each type of command has a `PlayerController` and `AIController`, which generate and/or call the commands to influence an Entity. Note that "AI" here means a repeating timer that executes a random command on timeout.


### Persistent Commands
This implementation type of commands can also be described as single-instance or variable-input commands. When using one, you invoke the same instance of a command repeatedly, giving the method it encapsules its parameters directly.

This commands [base class](./persistent_commands/persistent_command.gd) in this project looks something like this:
```gdscript
class_name PersistentCommand
extends RefCounted

@warning_ignore("unused_parameter")
func execute(entity: Entity, data: Object = null) -> void:
	push_error("Command execute not implemented")
```
> 💡 **Note**: I explicitly inherit `RefCounted` for clarity.

There are several differences from the first example of a command.

`@warning_ignore("unused_parameter")` does what it says: it makes the compiler ignore the `unused_paramter` warning, removing it from the code editor warnings and the debugger. Many people I know find it easy to ignore warnings in those areas, but I like to keep them clean. \
We ignore this warning because `PersistentCommand` is a base class; the `execute` function is meant to be overridden by its child classes and its parameters are meant for exactly those, not for the base class itself. \
That `push_error` is there for the same reason. Since we do not have abstract classes or interfaces, it is useful to have something else tell us if we made a mistake when overriding the function.

Now, for the parameters. The setup of this project specifies that all planned commands affect an Entity. Handing its reference over like this is an example of [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection). \
On the other hand, `data` is for *everything else* a command might need. To keep this as type safe as possible, [inner classes](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#inner-classes) are used to clearly define the data parameters.

For an example, let's look at the [persistent command implementation for moving an entity](./persistent_commands/per_movement_command.gd):
```gdscript
class_name PerMovementCommand
extends PersistentCommand


func execute(entity: Entity, data: Object = null) -> void:
	if data is not Params:
		push_error("Movement Command did not get the correct Params")
		return;
	
	entity.move((data as Params).direction)


class Params:
	var direction: Vector2i
	
	func _init(dir: Vector2i) -> void:
		direction = dir
``` 
The inner class `Params` is defined with the property `direction`




Aufbau?
- was ist die command pattern (core)
- wofür verwendet man die command pattern (abstrakt und vllt ein paar bsp von wikipedia)
- Disclaimer
- Persistent Commands (vllt auch single-instance / variable-input commands)
- Discrete Commands (vllt auch instanced commands)