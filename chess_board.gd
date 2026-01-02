@tool
class_name ChessBoardNode
extends Node2D

const LENGTH = 810
const CELL_LENGTH = LENGTH / 8

const COLUMNS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
const ROWS =    ['1', '2', '3', '4', '5', '6', '7', '8']


func _ready() -> void:
	if Engine.is_editor_hint():
		add_markers()

func add_markers():
	for row in range(8):
		for col in range(8):
			var node = Node2D.new()
			node.position = Vector2(CELL_LENGTH * col + CELL_LENGTH / 2, CELL_LENGTH * row + CELL_LENGTH / 2)
			node.name = COLUMNS[col] + ROWS[row]
			node.add_child(Marker2D.new())
			add_child(node)

func indices_to_coordinates(column: int, row: int):
	return COLUMNS[column] + ROWS[row]

func put_in_cell(column: int, row: int, node: Node):
	var coordinates = indices_to_coordinates(column, row)
	var cell = find_child(coordinates)
	if cell:
		cell.add_child(node)
	else:
		cell = Node2D.new()
		cell.position = Vector2(CELL_LENGTH * column + CELL_LENGTH / 2, CELL_LENGTH * row + CELL_LENGTH / 2)
		cell.name = coordinates
		add_child(cell)
		put_in_cell(column, row, node)
