# CommandGodot
Eine saubere Beispielimplementierung des Command Patterns in Godot mit zusätzlichen Visualisierungen.

**Erstellt in Godot 4.4.1**. Wenn 4.5 abstrakte Klassen hinzufügt, können die meisten der 'Basis'-Klassen hier leicht angepasst werden.

## Verwendung und Ziel
Dies soll ein schriftliches Tutorial sein, was die Command Pattern für [objektorientierte Programmierung](https://en.wikipedia.org/wiki/Object-oriented_programming) erklärt. \
Das Hauptaugenmerk liegt auf dem Verständnis des Zwecks, des Kernkonzepts und der Funktionalität des Musters.

Das Projekt versucht den [SOLID](https://en.wikipedia.org/wiki/SOLID) Prinzipien der Programmierung und dem [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) zu folgen.

## Was ist die Command Pattern?
Robert Nystroms Tagline bricht es auf das wesentliche herunter:
> A command is a reified method call.

Sinnvollerweise fügt er eine Erklärung für "reify" bei, die auf "etwas zu einem Ding machen" hinausläuft.

Ich möchte dieses Verständnis noch direkter machen (vor allem für Leute, die mit objektorientierter Programmierung vertraut sind):
> A command is an object wrapping a method. (Ein Befehl ist ein Objekt, das eine Methode umhüllt.)

Um das zu demonstrieren, haben wir eine Methode:
```gdscript
func greet() -> void:
    print("Hallo Welt!")
```
Wir *könnten* das einfach in eine Klasse packen und damit abschließen:
```gdscript
class_name GreetCommand

func greet() -> void:
    print("Hallo Welt!")
```
Aber jetzt haben wir nur ein Objekt, das eine einzige spezifische Aktion ausführen kann, die wir immer direkt referenzieren müssen.

GDScript hat zwar *noch* keine abstrakten Klassen und Methoden, aber es gibt
Vererbung:
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

> 💡 **Anmerkung**: In GDScript wird implizit `RefCounted` erweitert, wenn die Vererbung nicht explizit definiert ist (kein "extends" wurde verwendet) (siehe die [docs](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#inheritance)).

### Wofür wird sie verwendet?
Eine Methode wie ein Objekt zu behandeln ermöglicht mehrere nützliche Muster, einschließlich **Undo/Redo**-Funktionalität, **Command Queues** und **Scheduling**, und **Macro Commands** (Batch-Operationen).

Von den SOLID-Prinzipien folgt oder fördert die Command Pattern intrinsisch den Single-Responsibility, Open-Closed und Liskov Substitution Prinzipien.

Allgemeine Vorteile sind:
- **Entkopplung**: Das Objekt, das den Command aufruft, muss nichts über den Empfänger wissen oder darüber, wie die Aktion ausgeführt wird.
- **Erweiterbarkeit**: Neue Commands können ohne Änderung des bestehenden Codes hinzugefügt werden.

Die direktesten Nachteile sind:
- **Erhöhte Code-Komplexität**: Jeder Command wird zu einem neuen Objekt, das man organisieren und verwalten muss.
- **Potenzialiell schwierigere Fehlersuche**: Eine stärkere Entkopplung und Abstraktion kann Debugging erschweren.
- **Zustandsverwaltung**: Wenn Commands rückgängig gemacht werden können, erhöht die Speicherung und Wiederherstellung ihres Zustands die Komplexität und kann fehleranfällig sein.

Weitere Beispiele für die Verwendung des Musters findet man auf seiner [Wikipedia](https://en.wikipedia.org/wiki/Command_pattern#Uses) Seite.


## Implementierung von Commands  
### Hinweis  
In diesem Projekt verwende ich meine eigenen Bezeichnungen von *persistenten* und *diskreten* Commands.  

Obwohl diese Unterscheidung häufig in Erklärungen des Command Patterns vorkommt (siehe [Wikipedia](https://en.wikipedia.org/wiki/Command_pattern#Terminology) oder [Game Programming Patterns](https://gameprogrammingpatterns.com/command.html#undo-and-redo)), konnte ich bei einer kurzen Recherche keine Fälle finden, in denen diese Unterscheidung explizit benannt wurde.  


### Projekt-Setup
Dieses Projekt soll das Pattern demonstrieren, indem zwei Commands jedes Typs implementiert werden (ein `Movement`- und ein `Color`-Command), die beide Instanzen einer `Entity` beeinflussen, die sich auf einem 2D-Raster bewegt. Außerdem wird ein einfaches Undo/Redo-System implementiert, das für bessere Verständlichkeit visualisiert wird.

<img src="./images/overview.png" alt="Übersicht der Hauptszene" style="max-width: 500px; height: auto;" />

\
Um Entkopplung mit dem Command Pattern zu demonstrieren, hat jeder Command-Typ einen `PlayerController` und einen `AIController`, der die Commands generiert und/oder aufruft, um eine Entity zu beeinflussen. „AI“ bezieht sich hier lediglich auf einen wiederholten Timer, der bei Ablauf einen zufälligen Command ausführt.

Für jeden Command-Typ gibt es also einen `EntityController`, der eine Referenz auf die zu steuernde Entity sowie einige Basis-Properties und -Funktionen enthält (für die Implementierung siehe [PerEntityController](../persistent_commands/per_entity_controller.gd) und [DisEntityController](../discrete_commands/dis_entity_controller.gd)). Diese Basisklasse wird durch einen `PlayerController` und `AIController` erweitert, die jeweils basierend auf User Input bzw. einem Timer Commands für die Entity erzeugen.
<img src="./images/Controller_UML.png" alt="UML-Diagramm des Entity-, Player- und AIControllers" style="max-width: 400px; height: auto;">

> 💡 **Hinweis**: In GDScript ist es Best Practice, virtuellen Methoden oder privaten Methoden und Properties einen Unterstrich voranzustellen. Siehe den [Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#functions-and-variables).

Dieses Setup ermöglicht die Verwendung eines Dropdown-Menüs, um zwischen den Implementierungen eines `EntityController` für eine Entity zu wählen:
<img src="./images/Entity_Dropdown.png" alt="Der Entity-Inspector-Tab in Godot, der ein Dropdown-Menü zur Auswahl des EntityControllers zeigt"  style="max-width: 300px; height: auto;">



### Persistente Commands
Diese Art der Implementierung kann auch als Single-Instance- oder Variable-Input-Commands beschrieben werden. Bei ihrer Verwendung wird dieselbe Instanz eines Commands wiederholt aufgerufen, wobei die gekapselte Methode ihre Parameter direkt übergeben bekommt.

Die [Basisklasse](../persistent_commands/persistent_command.gd) dieser Commands sieht in diesem Projekt ungefähr so aus:  
```gdscript
class_name PersistentCommand
extends RefCounted

@warning_ignore("unused_parameter")
func execute(entity: Entity, data: Object = null) -> void:
	push_error("Command execute not implemented")
```
> 💡 **Hinweis**: Ich erbe explizit von `RefCounted` zur Verdeutlichung.

Es gibt mehrere Unterschiede zum ersten Beispiel eines Commands.

`@warning_ignore("unused_parameter")` macht genau das, was es aussagt: es bringt den Compiler dazu, die Warnung `unused_parameter` zu ignorieren, sodass sie nicht im Code-Editor oder Debugger erscheint. Viele Godot Devs die ich kenne finden es leicht, Warnungen in diesen Bereichen zu ignorieren, aber ich halte es gerne sauber. \
Wir ignorieren diese Warnung, weil `PersistentCommand` eine Basisklasse ist; die `execute`-Funktion soll von den Kindklassen überschrieben werden, und ihre Parameter sind genau für diese vorgesehen, nicht für die Basisklasse selbst. \
Das `push_error` ist dort aus demselben Grund. Da wir keine abstrakten Klassen oder Interfaces haben, ist es nützlich, anders darauf hingewiesen zu werden, wenn wir beim Überschreiben der Funktion einen Fehler gemacht haben.

Nun zu den Parametern. Dem Setup des Projects nach beeinflussen alle geplanten Commands eine Entity. Ihre Referenz so zu übergeben ist ein Beispiel für [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection). \
`data` hingegen ist für *alles andere* gedacht, was ein Command eventuell benötigt. Um dies so typsicher wie möglich zu halten, werden [innere Klassen](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#inner-classes) verwendet, um die Datenparameter klar zu definieren.

Als Beispiel schauen wir uns die [Implementierung](../persistent_commands/per_movement_command.gd) eines persistenten Commands zum Bewegen einer Entity an:  
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
Die `Params`-Klasse ist ein kleines Pattern, das für jeden Datenparameter, den ein spezifisches persistentes Command benötigt, konsistent beibehalten werden kann. Der Command-Aufruf, um eine Entity nach rechts zu bewegen, könnte also so aussehen:  
```gdscript
var params = PerMovementCommand.Params.new(Vector2i.RIGHT)
movement_command.execute(entity, params)
```
Dabei wird dieselbe Instanz des `PerMovementCommand` verwendet und für jede Bewegung ein neues `Params` erzeugt. Diese Instanz wird in der Basisklasse [PerEntityController](../persistent_commands/per_entity_controller.gd) aufgesetzt:  
```gdscript
class_name PerEntityController
extends Node

var entity: Entity

var movement_command := PerMovementCommand.new()
var color_command := PerColorCommand.new()
```
Der [PerPlayerController](../persistent_commands/per_player_controller.gd) erzeugt die Parameter basierend auf der Nutzereingabe, während der [PerAIController](../persistent_commands/per_ai_controller.gd) eine zufällige Richtung auswählt, in die er sich bewegen darf.

\
**Zusammenfassung**
- Instanzen von persistenten Commands werden einmal erzeugt, wenn das Skript geladen wird  
- Dieselbe Instanz wird wiederholt verwendet  
- Der `execute`-Methode dieser Instanz werden bei jedem Aufruf die Parameter übergeben  

Obwohl dies stärker entkoppelt und erweiterbarer ist als das direkte Aufrufen einer Methode, ermöglicht es keine Systeme wie Undo/Redo oder Command Queues.


### Diskrete Commands
Diese können auch als 'instanzierte Commands' beschrieben werden. Anstatt dieselbe Command-Instanz mit unterschiedlichen Parametern wiederholt aufzurufen, wird für jede Ausführung eine eigene Command-Instanz erzeugt. \
Schauen wir uns die Unterschiede in der [Basisklasse](../discrete_commands/discrete_command.gd) an:  
```gdscript
class_name DiscreteCommand
extends RefCounted

var _entity: Entity

func _init(entity: Entity) -> void:
	_entity = entity

func execute() -> void:
	push_error("Command execute not implemented")

func reverse() -> void:
	push_error("Command reverse not implemented")

```
Bei dieser Art der Implementierung ist ein einzelnes Command immer nur für einen spezifischen Parametersatz vorgesehen. Diese werden daher nicht beim Funktionsaufruf selbst übergeben, sondern bereits im Konstruktor `_init`. \
So wie beim `PersistentCommand` der `entity`-Parameter vom `data`-Parameter getrennt war, wird hier die Property `_entity` direkt in der Basisklasse deklariert.

Da die Parameter eines Commands in der Command-Instanz selbst gespeichert sind, erhält man die Möglichkeit, ihn auch umgekehrt auszuführen. \
Die [Implementierung](../discrete_commands/dis_movement_command.gd) des `MovementCommand` für diskrete Commands dient hier als Beispiel:  
```gdscript
class_name DisMovementCommand
extends DiscreteCommand

var _direction: Vector2i

func _init(entity: Entity, direction: Vector2i) -> void:
	super(entity)
	_direction = direction

func execute() -> void:
	_entity.move(_direction)

func reverse() -> void:
	_entity.move(-_direction)
```
> 💡 **Hinweis**: Das `super` keyword innerhalb einer überschriebenen Funktion erlaubt es, die gleichnamige Funktion der geerbten Klasse aufzurufen. Geerbte Klassen werden in GDScript nicht „base“ oder „parent“ classes genannt, sondern `super classes`. Siehe die [Dokumentation](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#inheritance).

Da `_direction` ein einfacher 2D-Vektor ist, kann er leicht umgekehrt werden.

Das [Command](../discrete_commands/dis_color_command.gd) zum Ändern der Entity-Farbe benötigte dafür eine zusätzliche Property:  
```gdscript
class_name DisColorCommand
extends DiscreteCommand

var _picked_color: Color
var _previous_color: Color

func _init(entity: Entity, color: Color) -> void:
	super(entity)
	_picked_color = color

func execute() -> void:
	_previous_color = _entity.get_sprite_color()
	_entity.set_sprite_color(_picked_color)

func reverse() -> void:
	_entity.set_sprite_color(_previous_color)
```


### Undo/Redo
Mit instanzierten, diskreten Commands, die eine Methode zum Rückgängigmachen ihrer Ausführung besitzen, haben wir bereits die wichtigsten Grundlagen für ein einfaches Undo/Redo-System. \
Um zu wissen, welche Commands genau rückgängig gemacht werden sollen, müssen wir ihre Ausführung mitverfolgen. Dafür können wir einen Undo-Stack implementieren:  
```gdscript
const MAX_STACK_LENGTH: int = 30

var _current_index: int
var _executed_commands: Array[DiscreteCommand] = []
```

> 💡 **Hinweis**: „Stack“ beschreibt eine Datenstruktur (hier ein Array), die wie ein wörtlicher Stapel behandelt wird. Man legt etwas oben auf den Stapel und nimmt vom oberen Ende des Stapels (das [Last-In-First-Out](https://www.geeksforgeeks.org/dsa/lifo-last-in-first-out-approach-in-programming/)-Prinzip). GDScript unterstützt einen solchen Workflow mit eingebauten Methoden wie `append()` und `pop_back()` (siehe die [Dokumentation](https://docs.godotengine.org/en/stable/classes/class_array.html)).

Ein Limit wie `MAX_STACK_LENGTH` sollte immer implementiert werden, hier ist es jedoch absichtlich klein gewählt, um den Stack in der UI leichter visualisieren zu können.

Wenn wir *nur* Undo implementieren wollten, würden wir auch tatsächlich `Array.pop_back()` nutzen und alle rückgängig gemachten Commands verwerfen. Da wir jedoch auch Redo ermöglichen möchten, merken wir uns stattdessen den aktuellen `_current_index`. Das bedeutet:
- wenn wir ein Command rückgängig machen, bewegt sich `_current_index` um 1 nach unten im Stack.  
- wenn wir ein Command wiederholen (Redo), bewegt er sich um 1 nach oben.  
- wenn wir ein *neues* Command ausführen, während wir *nicht am oberen Ende* des Stacks sind, wird alles vor `_current_index` verworfen und das neue Command hinzugefügt.  

Wie erwähnt enthält das Projekt eine Visualisierung des Undo-Stacks, die angezeigt wird, wenn der `ControllerType` einer Entity auf eine Implementierung des [DisEntityController](../discrete_commands/dis_entity_controller.gd) gesetzt wird. \
Im Abschnitt [Projekt-Setup](#project-setup) kann man einen teilweise gefüllten Undo-Stack sehen.

So sieht es aus, nachdem einige Commands rückgängig gemacht wurden:
<img src="./images/Undo_Vis_Undone.png" alt="Hauptszene mit visualisiertem Undo-Stack, nachdem einige Commands rückgängig gemacht wurden" style="max-width: 500px; height: auto;" />  
Der graue Kreis, der `_current_index` repräsentiert, zeigt unsere aktuelle Position im Undo-Stack.  

Schauen wir uns als Beispiel die Command-Erzeugung im [DisPlayerController](../discrete_commands/dis_player_controller.gd) an:  
```gdscript
func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if !entity.enable:
		return

	var command: DiscreteCommand
	var direction := Vector2i(-2, -2)
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
```

Wenn eine Bewegungsrichtung oder die „color“-Aktion (im Projekt auf die Leertaste gelegt) ausgelöst wird, wird eine neue Instanz eines [DiscreteCommand](../discrete_commands/discrete_command.gd) erzeugt und der lokalen Variable `command` zugewiesen. Natürlich gilt: wenn sich die Entity nicht in die gewählte Richtung bewegen kann (weil sie am Rand des Rasters steht) oder die Eingabe nicht zu den geprüften Aktionen gehört (wodurch `command` null bleibt), wird die Funktion beendet ohne etwas zu tun.  

Als ein Beispiel der Entkopplung von Command-Erstellung und -Ausführung wird die Command-Instanz nicht sofort ausgeführt. Stattdessen wird sie der minimalistischen [CommandQueue](../discrete_commands/command_queue.gd) hinzugefügt, welche alle gesammelten Commands jeden Physics-Frame ausführt:
```gdscript
func _physics_process(_delta: float) -> void:
	process_queue()

func process_queue() -> void:
	for cmd in _queue:
		cmd.execute()
		UndoManager.add_executed(cmd)
	_queue.clear()
```
Eine derart entkoppelte Ausführung kann beispielsweise für verzögerte/geplante Ausführung, Netzwerksynchronisation oder verschiedene Automatisierungsaufgaben genutzt werden.

Für die detaillierte Undo/Redo-Implementierung siehe den [UndoManager](../discrete_commands/undo_manager.gd).
