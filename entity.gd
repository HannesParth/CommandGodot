class_name Entity
extends Area2D

enum ControllerType {
	AI,
	PLAYER
}

@export_category("Refs")
@export var grid: Grid2D
@export var controller_parent: Node

@export_category("Config")
@export var move_duration: float = 0.3
@export var move_transition: Tween.TransitionType = Tween.TransitionType.TRANS_BACK
@export var move_ease: Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export var controller_type: ControllerType = ControllerType.AI#:

var current_controller: PerEntityController

var is_moving: bool = false


func _ready() -> void:
	if grid == null:
		grid = get_parent() as Grid2D
	assert(grid)
	
	_set_controller_type(controller_type)


func _set_controller_type(value: ControllerType) -> void:
	if value == controller_type && current_controller != null:
		return
	
	for child in controller_parent.get_children():
		child.queue_free()
	
	controller_type = value
	if controller_type == ControllerType.AI:
		current_controller = PerAIController.new(self)
	else:
		current_controller = PerPlayerController.new(self)
	
	controller_parent.add_child(current_controller)
	print("Set controller: " + ControllerType.keys()[controller_type])


func move(dir: Vector2i) -> void:
	if is_moving:
		return
	
	var current_cell := grid.cell_at_position(position)
	var new_cell = current_cell + dir
	var target = grid.get_cell_position(new_cell, Grid2D.CellPosition.CENTER)
	
	if target == Vector2i(-1, -1):
		return
	
	_tween_movement(target)


# see https://easings.net for Transition exampels
func _tween_movement(target: Vector2) -> void:
	is_moving = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target, move_duration)\
		.set_trans(move_transition)\
		.set_ease(move_ease)
	
	await tween.finished
	is_moving = false
