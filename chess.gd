@tool
extends Node2D

const chess_board_res = preload("res://chess_board.tscn")
const chess_piece_res = preload("res://chess_piece.tscn")

const ChessPieceType = ChessPieceNode.Type
const ChessColour = ChessPieceNode.Colour

var chess_board: ChessBoardNode = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chess_board = chess_board_res.instantiate()
	chess_board.ready.connect(ready_after_chess_board_ready)
	add_child(chess_board)

func ready_after_chess_board_ready():
	chess_board.chess_board_cell_input_event.connect(chess_board_cell_input_event)
	
	var back_line_types = [
		ChessPieceType.ROOK,
		ChessPieceType.KNIGHT,
		ChessPieceType.BISHOP,
		ChessPieceType.QUEEN,
		ChessPieceType.KING,
		ChessPieceType.BISHOP,
		ChessPieceType.KNIGHT,
		ChessPieceType.ROOK
	]
	for col in range(8):
		initialize_piece(back_line_types[col], ChessColour.WHITE, col, 0)
		initialize_piece(ChessPieceType.PAWN, ChessColour.WHITE, col, 1)
		initialize_piece(ChessPieceType.PAWN, ChessColour.BLACK, col, 6)
		initialize_piece(back_line_types[col], ChessColour.BLACK, col, 7)

func initialize_piece(type: ChessPieceType, colour: ChessColour, col: int, row: int):
	var col_name = ChessBoardNode.COLUMNS[col]
	#var row_name = ChessBoardNode.ROWS[row]
	var piece: ChessPieceNode = chess_piece_res.instantiate()
	var cell: Node2D = chess_board.get_cell(col, row)

	piece.type = type
	piece.colour = colour
	piece.global_position = cell.global_position
	piece.name = ChessColour.keys()[colour] + "-" + ChessPieceType.keys()[type] + "-" + col_name
	piece.cell = cell
	piece.z_index = 1
	# don't handle input event of individual chess piece, instead handle event on each cell
	#piece.chess_piece_input_event.connect(chess_piece_input_event)

	$Pieces.add_child(piece)
	return piece

func on_cell_click(cell: Node2D):
	print(cell.name)

# don't handle input event of individual chess piece, instead handle event on each cell
#var _pressed_on_piece: ChessPieceNode = null
#var _clicked_on_piece: ChessPieceNode = null
#func chess_piece_input_event(chess_piece_node: ChessPieceNode, event: InputEvent):
	#if event is InputEventMouseButton:
		#if event.pressed:
			#_pressed_on_piece = chess_piece_node
		#elif chess_piece_node == _pressed_on_piece:
			#_pressed_on_piece = null
			#_clicked_on_piece = chess_piece_node
			#print(chess_piece_node.name)
		#else:
			#_pressed_on_piece = null
			#_clicked_on_piece = null

var _pressed_on_cell: Node2D = null
func chess_board_cell_input_event(cell: Node2D, event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed:
			_pressed_on_cell = cell
		elif cell == _pressed_on_cell:
			_pressed_on_cell = null
			on_cell_click(cell)
		else:
			_pressed_on_cell = null
