class_name PerAIController
extends PerEntityController

@export var break_time: float = 0.8

var action_timer: Timer
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var directions: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT,
]

func _ready() -> void:
	action_timer = Timer.new()
	action_timer.one_shot = false
	action_timer.wait_time = break_time
	action_timer.timeout.connect(_perform_action)
	add_child(action_timer)
	action_timer.start()


func _perform_action() -> void:
	var actions: Array[Callable] = [_move, _send_color_command]
	var random := actions.pick_random() as Callable
	random.call()


func _move() -> void:
	var dir: Vector2i = directions.pick_random()
	var params = PerMovementCommand.Params.new(dir)
	movement_command.execute(entity, params)
