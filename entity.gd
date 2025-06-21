class_name Entity
extends Area2D
## The base entity moved and affected in this tutorial.
##
## This script defines the functionality of the entity. It has functions 
## to set its own controller, move itself, and change its sprites color,
## which includes a particle system.
## There are private functions to tween its movement, an arrow signaling the 
## direction it is moving in, and the color change.


enum ControllerType {
	PER_AI,
	PER_PLAYER,
	DIS_AI,
	DIS_PLAYER
}

@export_group("Refs")
@export var grid: Grid2D
@export var controller_parent: Node
@export var arrow_line: Line2D
@export var sprite: Sprite2D
@export var particles: CPUParticles2D

@export_group("Config")
@export var enable: bool = true
@export var move_duration: float = 0.3
@export var controller_type: ControllerType = ControllerType.PER_AI
@export var colors: Array[Color]

@export_group("Tweens")
@export var move_transition: Tween.TransitionType = Tween.TransitionType.TRANS_BACK
@export var move_ease: Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export var arrow_transition: Tween.TransitionType
@export var arrow_ease: Tween.EaseType

var current_controller: Node

var is_moving: bool = false



func _enter_tree() -> void:
	ExecutionManager.register(self)


func _ready() -> void:
	# Null-assert all needed references and properties
	assert(grid)
	assert(controller_parent)
	assert(arrow_line)
	assert(sprite)
	assert(particles)
	assert(colors)
	assert(colors.size() > 0)
	assert(colors.has(Color.WHITE))
	
	# Make sure the arrow line is hidden
	arrow_line.hide()
	
	# Set the controller of this entity
	_set_controller_type(controller_type)


## Sets up the current controller based on the given [enum ControllerType]. [br]
## Adds the new controller to the as a child of the [param controller_parent]
func _set_controller_type(value: ControllerType) -> void:
	if value == controller_type && current_controller != null:
		return
	
	for child in controller_parent.get_children():
		child.queue_free()
	
	controller_type = value
	match value:
		ControllerType.PER_AI:
			current_controller = PerAIController.new(self)
		ControllerType.PER_PLAYER:
			current_controller = PerPlayerController.new(self)
		ControllerType.DIS_AI:
			current_controller = DisAIController.new(self)
		ControllerType.DIS_PLAYER:
			current_controller = DisPlayerController.new(self)
	
	controller_parent.add_child(current_controller)


## Moves the [Entity] in the given direction on the grid. [br]
## Does not move if the direction is off the grid or if it is currently 
## moving.
func move(dir: Vector2i) -> void:
	if is_moving:
		return
	
	var current_cell: Vector2i = grid.get_cell_at_position(position)
	var new_cell: Vector2i = current_cell + dir
	if !grid.is_cell_in_grid(new_cell):
		print_debug("You (" + name + ") cannot move in this direction.")
		return
	
	var target: Vector2i = grid.get_cell_position(new_cell, Grid2D.CellPosition.CENTER)
	if target == Vector2i(-1, -1):
		return
	
	_tween_movement(target)
	_tween_arrow(dir)


## Checks wether there is a grid cell in the given direction.
## For use by the [member Entity.current_controller] to prevent
## the creation of unusable commands.
func can_move_in_direction(dir: Vector2i) -> bool:
	var current_cell: Vector2i = grid.get_cell_at_position(position)
	var new_cell: Vector2i = current_cell + dir
	return grid.is_cell_in_grid(new_cell)


## Sets the [member CanvasItem.self_modulate] of the [Entity]s [member Entity.sprite]. [br]
## Also sets the particle systems [member CPUParticles2D.color_ramp] accordingly
## and starts it. [br]
## Does nothing if the [Entity] is disabled.
func set_sprite_color(col: Color) -> void:
	particles.color_ramp.set_color(0, sprite.self_modulate)
	particles.color_ramp.set_color(1, col)
	particles.restart()
	_tween_color(sprite, col)


## Returns the [member CanvasItem.self_modulate] color of the [member Entity.sprite]
func get_sprite_color() -> Color:
	return sprite.self_modulate


## Tweens the Entities movement with the set [member Entity.move_transition] and
## [member Entity.move_ease] for the [member Entity.move_duration]. [br]
## Sets [member Entity.is_moving] at the start and end of the tween. [br]
## See [url]https://easings.net[/url] for transition and easing curves.
func _tween_movement(target: Vector2) -> void:
	is_moving = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target, move_duration)\
		.set_trans(move_transition)\
		.set_ease(move_ease)
	
	await tween.finished
	is_moving = false


## Tweens the Entities direction arrow with the set [member Entity.arrow_transition] 
## and [member Entity.arrow_ease] for half the [member Entity.move_duration]. [br]
## Rotates the [member Entity.arrow_line] in the movement direction.
## See [url]https://easings.net[/url] for transition and easing curves.
func _tween_arrow(dir: Vector2i) -> void:
	# Get angle of directon + 90°
	# Since the default angle is relative to the x-axis
	var angle := Vector2(-dir).angle() + PI / 2
	arrow_line.rotation = angle
	arrow_line.scale = Vector2(1, 0.1)
	
	arrow_line.show()
	var tween = get_tree().create_tween()
	tween.tween_property(arrow_line, "scale", Vector2.ONE, move_duration / 2)\
		.set_trans(arrow_transition)\
		.set_ease(arrow_ease)
	tween.tween_property(arrow_line, "scale", Vector2(1, 0.1), move_duration / 2)\
		.set_trans(arrow_transition)\
		.set_ease(arrow_ease)
	
	await tween.finished
	arrow_line.hide()


## Tweens the [param target]s [member CanvasItem.self_modulate] to the given
## [param color] over 0.5 seconds.
func _tween_color(target: Node2D, color: Color) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(target, "self_modulate", color, 0.5)
