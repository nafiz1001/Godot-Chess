@tool
extends Node2D

const chess_board_scene = preload("res://chess_board.tscn")
const chess_piece_res = preload("res://chess_piece.tscn")

const ChessPieceType = ChessPieceNode.Type
const ChessColour = ChessPieceNode.Colour

var chess_board: ChessBoardNode = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chess_board = chess_board_scene.instantiate()
	chess_board.name = "Chess_Board"
	chess_board.ready.connect(ready_after_chess_board_ready)
	add_child(chess_board)

func ready_after_chess_board_ready():
	chess_board.input_event.connect(chess_board_event)
	
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
	var square = Vector2i(col, row)
	var col_name = ChessBoardNode.COLUMNS[col]
	#var row_name = ChessBoardNode.ROWS[row]
	var piece: ChessPieceNode = chess_piece_res.instantiate()

	piece.type = type
	piece.colour = colour
	piece.global_position = chess_board.square_to_global_position(square)
	piece.name = ChessColour.keys()[colour] + "-" + ChessPieceType.keys()[type] + "-" + col_name
	piece.square = Vector2i(col, row)
	piece.z_index = 1
	# don't handle input event of individual chess piece, instead handle event on each square
	#piece.chess_piece_input_event.connect(chess_piece_input_event)
	$Pieces.add_child(piece)
	
	chess_board.chess_pieces[ChessBoardNode.indices_to_coords(col, row)] = piece
	
	return piece

var active_piece: ChessPieceNode = null
func on_square_click(square: Vector2i):
	var coords = ChessBoardNode.indices_to_coords(square.x, square.y)
	var existing_piece = chess_board.chess_pieces.get(coords, null)
	if active_piece:
		active_piece.position = chess_board.square_to_global_position(square)
		chess_board.chess_pieces[coords] = active_piece

		chess_board.chess_pieces.erase(ChessBoardNode.indices_to_coords(active_piece.square.x, active_piece.square.y))
		active_piece.square = square
		
		if existing_piece:
			existing_piece.queue_free()

		active_piece = null
	else:
		active_piece = existing_piece

var _pressed_on_square = null
func chess_board_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var square = chess_board.global_position_to_square(event.global_position)
		if event.pressed:
			_pressed_on_square = square
		elif _pressed_on_square != null and square == _pressed_on_square:
			_pressed_on_square = null
			on_square_click(square)
		else:
			_pressed_on_square = null
