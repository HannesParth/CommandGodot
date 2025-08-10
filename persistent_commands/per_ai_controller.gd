class_name PerAIController
extends PerEntityController
## Very simple non-player implementation of the [PerEntityController].
##
## This implementation performs random actions for the controlled [Entity]
## based on a [Timer]. For this tutorial, it either moves the entity in a 
## random direction or changes the entities color.


## The time between actions in seconds.
@export var break_time: float = 1.0

var action_timer: Timer

## The directions to move in set up as an [Array], because these have
## [method Array.pick_random].
var directions: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT,
]


## Setting up the [member DisAIController.action_timer]
func _ready() -> void:
	action_timer = Timer.new()
	action_timer.one_shot = false
	action_timer.wait_time = break_time
	action_timer.timeout.connect(_perform_action)
	add_child(action_timer)
	action_timer.start()


func _perform_action() -> void:
	if !entity.enable:
		return
	
	var actions: Array[Callable] = [_move, _send_color_command]
	var random := actions.pick_random() as Callable
	random.call()


func _move() -> void:
	var dir: Vector2i = _get_viable_directions().pick_random()
	var params := PerMovementCommand.Params.new(dir)
	movement_command.execute(entity, params)


func _get_viable_directions() -> Array[Vector2i]:
	var viable: Array[Vector2i] = []
	for dir in directions:
		if entity.can_move_in_direction(dir):
			viable.append(dir)
	
	return viable
