class_name ChessBoard
extends Object

const COLUMNS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
const ROWS = ['8', '7', '6', '5', '4', '3', '2', '1']

static func indices_to_coords(col: int, row: int) -> String:
	return COLUMNS[col] + ROWS[row]

static func vec_to_coords(square: Vector2i) -> String:
	return indices_to_coords(square.x, square.y)

static func vec_to_index(square: Vector2i) -> int:
	return square.y * 8 + square.x
static func index_to_vec(index: int) -> Vector2i:
	@warning_ignore("integer_division")
	var row = index / 8
	var col = index % 8
	return Vector2i(col, row)

static func coords_to_vec(coords: String) -> Vector2i:
	var col = COLUMNS.find(coords.substr(0, 1))
	var row = ROWS.find(coords.substr(1, 1))
	return Vector2i(col, row)

static func out_of_bounds(square: Vector2i) -> bool:
	return square.x < 0 or square.x >= 8 or square.y < 0 or square.y >= 8
