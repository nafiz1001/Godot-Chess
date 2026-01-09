class_name ChessBoardNode
extends Node2D

var LENGTH: float:
	get():
		return ($MeshInstance2D.mesh as PlaneMesh).size.x
var CELL_LENGTH: float:
	get():
		return LENGTH / float(8)
var GLOBAL_LENGTH: float:
	get():
		return LENGTH * global_scale.x
var GLOBAL_CELL_LENGTH: float:
	get():
		return CELL_LENGTH * global_scale.x

const COLUMNS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
const ROWS =    ['8', '7', '6', '5', '4', '3', '2', '1']

# The origin of the chess board is assumed to be on the top left corner of the board

func square_to_global_position(square: Vector2i) -> Vector2:
	return (Vector2(square.x * GLOBAL_CELL_LENGTH, square.y * GLOBAL_CELL_LENGTH)
		+ Vector2(GLOBAL_CELL_LENGTH, GLOBAL_CELL_LENGTH) / 2
		+ global_position)
func global_position_to_square(_position: Vector2) -> Vector2i:
	var relative_position = _position - global_position
	return Vector2i(
		floor(relative_position.x / GLOBAL_CELL_LENGTH),
		floor(relative_position.y / GLOBAL_CELL_LENGTH)
	)

static func indices_to_coords(col: int, row: int) -> String:
	return COLUMNS[col] + ROWS[row]
static func vec_to_coords(square: Vector2i) -> String:
	return indices_to_coords(square.x, square.y)
static func coords_to_vec(coords: String) -> Vector2i:
	var col = COLUMNS.find(coords.substr(0, 1))
	var row = ROWS.find(coords.substr(1, 1))
	return Vector2i(col, row)
static func out_of_bounds(square: Vector2i) -> bool:
	return square.x < 0 or square.x >= 8 or square.y < 0 or square.y >= 8

signal on_square_click(square: Vector2i)
var _pressed_on_square = null
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var square = global_position_to_square(event.global_position)
		if event.pressed:
			_pressed_on_square = square
		elif _pressed_on_square != null and square == _pressed_on_square:
			_pressed_on_square = null
			on_square_click.emit(square)
		else:
			_pressed_on_square = null
