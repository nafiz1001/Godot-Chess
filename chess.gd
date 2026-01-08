@tool
extends Node2D

const chess_board_scene = preload("res://chess_board.tscn")
const chess_piece_res = preload("res://chess_piece.tscn")

const ChessPieceType = ChessPieceNode.Type
const ChessColour = ChessPieceNode.Colour

var chess_board: ChessBoardNode = null

# key is coordinates
var active_chess_pieces: Dictionary[String, ChessPieceNode] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chess_board = chess_board_scene.instantiate()
	chess_board.name = "Chess_Board"
	add_child(chess_board)

	chess_board.on_square_click.connect(on_square_click)
	
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
		initialize_piece(back_line_types[col], ChessColour.BLACK, col, 0)
		initialize_piece(ChessPieceType.PAWN, ChessColour.BLACK, col, 1)
		initialize_piece(ChessPieceType.PAWN, ChessColour.WHITE, col, 6)
		initialize_piece(back_line_types[col], ChessColour.WHITE, col, 7)

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
	
	active_chess_pieces[ChessBoardNode.indices_to_coords(col, row)] = piece
	
	return piece

var active_square = null
var active_piece: ChessPieceNode = null
func on_square_click(new_square: Vector2i):
	var new_coords = ChessBoardNode.indices_to_coords(new_square.x, new_square.y)
	var existing_piece = active_chess_pieces.get(new_coords, null)
	var is_move_valid = (
		active_piece != null
		and ChessPieceNode.is_move_valid(active_piece, active_square, new_square)
		and (existing_piece == null or existing_piece.colour != active_piece.colour)
		and (active_piece.type != ChessPieceNode.Type.PAWN
			or (existing_piece == null and new_square.x == active_square.x)
			or (existing_piece != null and new_square.x != active_square.x and abs(new_square.y - active_square.y) == 1)))
	if is_move_valid:
		# put at new position
		active_piece.position = chess_board.square_to_global_position(new_square)
		# put at new square and replace whatever is existing
		active_chess_pieces[new_coords] = active_piece
		# erase from last square
		active_chess_pieces.erase(ChessBoardNode.indices_to_coords(active_square.x, active_square.y))

		if existing_piece:
			# hide killed piece
			existing_piece.global_position = Vector2(-100000, -100000)

		active_piece = null
		active_square = null
	else:
		active_piece = existing_piece
		active_square = new_square
