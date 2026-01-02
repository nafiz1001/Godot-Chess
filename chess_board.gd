@tool
class_name ChessBoardNode
extends Node2D

const LENGTH = 810
const CELL_LENGTH = LENGTH / 8

const COLUMNS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
const ROWS =    ['1', '2', '3', '4', '5', '6', '7', '8']


func _ready() -> void:
	for row in range(8):
		for col in range(8):
			var node = Node2D.new()
			node.position = Vector2(CELL_LENGTH * col + CELL_LENGTH / 2, CELL_LENGTH * row + CELL_LENGTH / 2)
			node.name = COLUMNS[col] + ROWS[row]
			if Engine.is_editor_hint():
				node.add_child(Marker2D.new())
			add_child(node)
