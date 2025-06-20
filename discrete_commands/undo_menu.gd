class_name UndoMenu
extends CanvasLayer


@export_group("Refs")
@export var play_button: Button
@export var pause_button: Button
@export var next_button: Button
@export var previous_button: Button
@export var array_elements_parent: HBoxContainer
@export var index_indicator: Panel


func _ready() -> void:
	play_button.pressed.connect(_on_button_resume)
	pause_button.pressed.connect(_on_button_pause)
	next_button.pressed.connect(_on_button_redo)
	previous_button.pressed.connect(_on_button_undo)
	
	UndoManager.command_added.connect(_on_command_added)
	UndoManager.command_undone.connect(_update_indicator)
	UndoManager.command_redone.connect(_update_indicator)
	
	_update_button_states()
	_clear_array_elements()
	_update_indicator(0)
	


#region On_Button Methods
func _on_button_pause() -> void:
	ExecutionManager.pause_execution()
	_update_button_states()


func _on_button_resume() -> void:
	ExecutionManager.resume_execution()
	_update_button_states()


func _on_button_undo() -> void:
	var index: int = UndoManager.undo()
	_update_indicator(index)


func _on_button_redo() -> void:
	var index: int = UndoManager.redo()
	_update_indicator(index)
#endregion


func _update_button_states() -> void:
	play_button.visible = ExecutionManager.is_paused
	pause_button.visible = !ExecutionManager.is_paused
	
	previous_button.disabled = !ExecutionManager.is_paused
	next_button.disabled = !ExecutionManager.is_paused


#region Array Visualization Methods
func _on_command_added(new_stack_size: int, new_current_index: int) -> void:
	_clear_array_elements()
	
	for i in new_stack_size:
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(20, 20)
		var label = Label.new()
		label.text = str(i)
		label.set_position(Vector2(4, 1))
		label.add_theme_font_size_override("font_size", 12)
		panel.add_child(label)
		array_elements_parent.add_child(panel)
	
	call_deferred("_update_indicator", new_current_index)


func _clear_array_elements() -> void:
	for child in array_elements_parent.get_children():
		child.free()

func _update_indicator(index: int) -> void:
	# No stack: hide indicator
	if UndoManager.stack_size == 0:
		index_indicator.hide()
		return
	
	# Command at index 0 was undone: hide indicator
	if index == -1:
		index_indicator.hide()
		return
		
	# Index is out of bounds
	if index < -1 || index >= array_elements_parent.get_child_count():
		push_error("Index given to indicator was out of bounds relative to the " + \
			"instantiated array elements. Given index: " + str(index) + \
			", Nr of elements: " + str(array_elements_parent.get_child_count()))
		return
	
	var element: Panel = array_elements_parent.get_child(index)
	var pos = element.global_position + Vector2(2.5, 22)
	
	index_indicator.set_global_position(pos)
	index_indicator.show()
#endregion
