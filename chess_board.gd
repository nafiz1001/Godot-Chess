@tool
class_name ChessBoardNode
extends Node2D

const BORDER_PADDING = 5
const LENGTH = (810 - BORDER_PADDING*2)
const CELL_LENGTH = LENGTH / 8

const COLUMNS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
const ROWS =    ['8', '7', '6', '5', '4', '3', '2', '1']

func _ready() -> void:
	for row in range(8):
		for col in range(8):
			var cell = create_area2d()
			cell.position = Vector2(CELL_LENGTH * (col + 0.5) + BORDER_PADDING, CELL_LENGTH * (row + 0.5) + BORDER_PADDING)
			cell.name = indices_to_coords(col, row)
			$Cells.add_child(cell)

func add_markers():
	for cell in $Cells.get_children():
		cell.add_child(Marker2D.new())

func indices_to_coords(col: int, row: int):
	return COLUMNS[col] + ROWS[row]

func get_cell(col: int, row: int):
	return $Cells.find_child(indices_to_coords(col, row), false, false)

static func create_area2d():
	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(CELL_LENGTH, CELL_LENGTH)
	shape.debug_color = Color(randf(), randf(), randf(), 0.25)
	area.add_child(shape)
	return area
