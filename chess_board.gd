@tool
class_name ChessBoardNode
extends Node2D

const BORDER_PADDING = 0
const LENGTH = (1024 - BORDER_PADDING*2)
const CELL_LENGTH = LENGTH / 8

const COLUMNS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
const ROWS =    ['8', '7', '6', '5', '4', '3', '2', '1']

signal input_event(viewport: Node, event: InputEvent, shape_idx: int)

func square_to_global_position(square: Vector2i) -> Vector2:
	return (Vector2(square.x * CELL_LENGTH, square.y * CELL_LENGTH)
		+ Vector2(CELL_LENGTH, CELL_LENGTH) / 2
		+ position)

func global_position_to_square(_position: Vector2) -> Vector2i:
	var relative_position = _position - position
	return Vector2i(floor(relative_position.x / CELL_LENGTH), floor(relative_position.y / CELL_LENGTH))

static func indices_to_coords(col: int, row: int) -> String:
	return COLUMNS[col] + ROWS[row]


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	input_event.emit(viewport, event, shape_idx)
