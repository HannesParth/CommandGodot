@tool
class_name Grid2D
extends Node2D
## Node for drawing an in-game-visible 2D grid.
##
## The setters of this script check each other and redraw the grid.
## It also has various utility functions to make the management of 
## objects on it easier. 
## For the purposes of this tutorial, all position management is assumed 
## to be for the grids direct children.

enum CellPosition {
	CENTER,
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
}

@export var cell_size := Vector2i(32, 32) :
	set (value):
		cell_size = value if value > Vector2i(0, 0) else Vector2i(16, 16)
		_set_grid_pixel_size(grid_size * cell_size, false)
		queue_redraw()

@export var grid_size := Vector2i(4, 4) :
	set (value):
		grid_size = value
		_set_grid_pixel_size(value * cell_size, false)
		queue_redraw()

@export var grid_color := Color(1, 1, 1, 0.2) :
	set (value):
		grid_color = value
		queue_redraw()

@export var line_width: float = -1.0 :
	set (value):
		line_width = value if value != 0 else -1.0
		queue_redraw()

var grid_point_size := Vector2i(128, 128)


## Draws the visible lines for the grid
func _draw():
	var modifier: float = 0
	if line_width != -1.0:
		modifier = line_width / 2
	
	for x in range(0, grid_point_size.x + 1, cell_size.x):
		draw_line(
			Vector2(x, -modifier), 
			Vector2(x, grid_point_size.y + modifier), 
			grid_color, 
			line_width)
	
	for y in range(0, grid_point_size.y + 1, cell_size.y):
		draw_line(
			Vector2(-modifier, y), 
			Vector2(grid_point_size.x + modifier, y), 
			grid_color, 
			line_width)


## Sets the pixel size of the grid to [param value]. [br]
## Snaps the actual value to a multiple of [member Grid2D.cell_size]
func _set_grid_pixel_size(value: Vector2i, redraw: bool) -> void:
	var adjusted_x = max(cell_size.x, int(value.x / cell_size.x) * cell_size.x)
	var adjusted_y = max(cell_size.y, int(value.y / cell_size.y) * cell_size.y)
	grid_point_size = Vector2i(adjusted_x, adjusted_y)
	
	if redraw:
		queue_redraw()


## Gets the position of a given [param cell] in the grids local space 
## depending on the given [param target] which is an enum 
## [enum Grid2D.CellPosition]. [br]
## Returns [code]Vector2i(-1, -1)[/code] if the [param cell] is not on the grid.
func get_cell_position(cell: Vector2i, target: CellPosition = CellPosition.CENTER) -> Vector2i:
	if !is_cell_in_grid(cell):
		push_error("Cell " + str(cell) + "is not on the grid.")
		return Vector2i(-1, -1)
	
	var cell_origin = cell * cell_size
	match target:
		CellPosition.CENTER:
			return cell_origin + cell_size / 2
		CellPosition.TOP_LEFT:
			return cell_origin
		CellPosition.TOP_RIGHT:
			return cell_origin + Vector2(cell_size.x, 0)
		CellPosition.BOTTOM_LEFT:
			return cell_origin + Vector2(0, cell_size.y)
		CellPosition.BOTTOM_RIGHT:
			return cell_origin + cell_size
		_:
			return cell_origin  # Fallback: top-left


## Gets the grid cell at the given [param pos]. [br]
## Returns [code]Vector2i(-1, -1)[/code] if the [param pos] is not on the grid.
## [br][br]
## [b]Important: [/b] pos has to be in the local space of the grid.
func get_cell_at_position(pos: Vector2) -> Vector2i:
	if !is_pos_on_grid(pos):
		push_error("Position" + str(pos) + "is not on the grid.")
		return Vector2i(-1, -1)
	
	var cell_x = int(pos.x / cell_size.x)
	var cell_y = int(pos.y / cell_size.y)
	return Vector2i(cell_x, cell_y)


## Snaps a given [param point] to a [param target] position of the cell
## the point is inside of.
## Returns [code]Vector2i(-1, -1)[/code] if the [param point] is not on the grid.
## [br][br]
## [b]Important: [/b] point has to be in the local space of the grid.
func snap_point_to_cell(
		point: Vector2, 
		target: CellPosition = CellPosition.CENTER) -> Vector2i:
	if !is_pos_on_grid(point):
		push_error("point" + str(point) + "is not on the grid.")
		return Vector2i(0, 0)
	
	var cell_x = int(point.x / cell_size.x)
	var cell_y = int(point.y / cell_size.y)
	var cell_origin = Vector2(cell_x * cell_size.x, cell_y * cell_size.y)
	
	match target:
		CellPosition.CENTER:
			return cell_origin + cell_size / 2
		CellPosition.TOP_LEFT:
			return cell_origin
		CellPosition.TOP_RIGHT:
			return cell_origin + Vector2(cell_size.x, 0)
		CellPosition.BOTTOM_LEFT:
			return cell_origin + Vector2(0, cell_size.y)
		CellPosition.BOTTOM_RIGHT:
			return cell_origin + cell_size
		_:
			return cell_origin  # Fallback: top-left


func is_pos_on_grid(pos: Vector2) -> bool:
	return (pos.x > 0 
		&& pos.y > 0 
		&& pos.x < grid_point_size.x 
		&& pos.y < grid_point_size.y)


func is_cell_in_grid(cell: Vector2i) -> bool:
	return (cell.x >= 0 
	&& cell.y >= 0 
	&& cell.x < grid_size.x 
	&& cell.y < grid_size.y)
