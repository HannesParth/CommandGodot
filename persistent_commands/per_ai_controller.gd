class_name PerAIController
extends PerEntityController

@export var break_time: float = 1.5

var action_timer: Timer
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	action_timer = Timer.new()
	action_timer.wait_time = break_time
	action_timer.timeout.connect(_perform_action)


func _perform_action() -> void:
	var actions: Array[Callable] = [_move]
	var random: Callable = actions.pick_random() as Callable
	random.call()


func _move() -> void:
	var dir := Vector2i(rng.randi_range(-1, 1), rng.randi_range(-1, 1))
	var params = PerMovementCommand.Params.new(dir)
	movement_command.execute(entity, params)
