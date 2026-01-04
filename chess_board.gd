@tool
class_name ChessBoardNode
extends Node2D

const BORDER_PADDING = 0
const LENGTH = (810 - BORDER_PADDING*2)
const CELL_LENGTH = LENGTH / 8

const COLUMNS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
const ROWS =    ['8', '7', '6', '5', '4', '3', '2', '1']

static var white_cell_texture = GradientTexture2D.new()
static var black_cell_texture = GradientTexture2D.new()

signal chess_board_cell_input_event(cell: Sprite2D, event: InputEvent)

func _ready() -> void:
	white_cell_texture.width = 1
	white_cell_texture.height = 1
	white_cell_texture.fill_from = Vector2(1, 1)
	white_cell_texture.fill_to = Vector2(1, 0)
	white_cell_texture.gradient = Gradient.new()
	
	black_cell_texture.width = 1
	black_cell_texture.height = 1
	black_cell_texture.fill_from = Vector2(0, 0)
	black_cell_texture.fill_to = Vector2(1, 0)
	black_cell_texture.gradient = Gradient.new()
	
	for row in range(8):
		for col in range(8):
			var cell = create_cell(col, row)
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

func create_cell(col: int, row: int):
	var sprite = Sprite2D.new()
	if (col + row * 8 + (row % 2)) % 2 == 0:
		sprite.texture = white_cell_texture
	else:
		sprite.texture = black_cell_texture
	sprite.scale = Vector2(CELL_LENGTH, CELL_LENGTH)

	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(1, 1)
	shape.debug_color = Color(randf(), randf(), randf(), 0.25)
	area.add_child(shape)

	sprite.add_child(area)
	
	area.input_pickable = true
	var input_event = func (_viewport: Node, event: InputEvent, _shape_idx: int):
		chess_board_cell_input_event.emit(sprite, event)
	area.input_event.connect(input_event)

	return sprite
