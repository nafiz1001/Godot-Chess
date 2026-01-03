@tool
class_name ChessBoardNode
extends Node2D

const LENGTH = 810
const CELL_LENGTH = LENGTH / 8

const COLUMNS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
const ROWS =    ['8', '7', '6', '5', '4', '3', '2', '1']


func _ready() -> void:
	for row in range(8):
		for col in range(8):
			var cell = Node2D.new()
			cell.position = Vector2(CELL_LENGTH * col + CELL_LENGTH / 2, CELL_LENGTH * row + CELL_LENGTH / 2)
			cell.name = indices_to_coords(col, row)
			$Cells.add_child(cell)

	if Engine.is_editor_hint():
		add_markers()

func add_markers():
	for cell in $Cells.get_children():
		cell.add_child(Marker2D.new())

func indices_to_coords(col: int, row: int):
	return COLUMNS[col] + ROWS[row]

func get_cell(col: int, row: int):
	return $Cells.find_child(indices_to_coords(col, row), false, false)
