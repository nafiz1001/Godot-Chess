@tool
class_name ChessNode
extends Node2D

const chess_board_scene = preload("res://chess_board.tscn")
const chess_piece_res = preload("res://chess_piece.tscn")

const ChessPieceType = ChessPieceNode.Type
const ChessColour = ChessPieceNode.Colour

var chess_board: ChessBoardNode

# key is coordinates
var active_chess_pieces: Dictionary[String, ChessPieceNode] = {}

func _ready() -> void:
	chess_board = chess_board_scene.instantiate() as ChessBoardNode
	chess_board.name = "Chess_Board"
	add_child(chess_board)
	
	ChessPieceNode.chess_board = chess_board

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
	var piece = chess_piece_res.instantiate() as ChessPieceNode

	piece.type = type
	piece.colour = colour
	piece.global_position = chess_board.square_to_global_position(square)
	piece.name = ChessColour.keys()[colour] + "-" + ChessPieceType.keys()[type] + "-" + col_name
	piece.z_index = 1
	# don't handle input event of individual chess piece, instead handle event on each square
	#piece.chess_piece_input_event.connect(chess_piece_input_event)
	$Pieces.add_child(piece)
	
	active_chess_pieces[ChessBoardNode.indices_to_coords(col, row)] = piece
	
	return piece

var active_square = null
var active_piece: ChessPieceNode
func on_square_click(new_square: Vector2i):
	var new_coords = ChessBoardNode.vec_to_coords(new_square)
	if active_piece == null or active_square == null:
		# select piece
		if active_chess_pieces.has(new_coords):
			active_square = new_square
			active_piece = active_chess_pieces[new_coords]
			active_piece.modulate = Color(0.8, 0.8, 1, 1)
			print("Selected piece at ", new_coords)
			print("Piece type: ", active_piece.type, " Colour: ", active_piece.colour)
			print("Possible moves: ", active_piece.moves(active_square, active_chess_pieces))
	else:
		var new_piece = active_chess_pieces.get(new_coords, null)
		if new_piece != null and new_piece.colour == active_piece.colour:
			# select different piece
			active_piece.modulate = Color(1, 1, 1, 1)
			active_square = new_square
			active_piece = new_piece
			active_piece.modulate = Color(0.8, 0.8, 1, 1)
		else:
			# try to move piece
			var moves = active_piece.moves(active_square, active_chess_pieces)
			for path in moves:
				for move in path:
					if move == new_square:
						# move piece
						var old_coords = ChessBoardNode.vec_to_coords(active_square)
						active_piece.global_position = chess_board.square_to_global_position(new_square)
						active_piece.modulate = Color(1, 1, 1, 1)
						
						active_chess_pieces.erase(old_coords)

						var captured_piece = active_chess_pieces.get(new_coords, null)
						if captured_piece != null:
							captured_piece.visible = false
						active_chess_pieces[new_coords] = active_piece
						
						active_square = null
						active_piece = null
						return
			# deselect piece
			active_piece.modulate = Color(1, 1, 1, 1)
			active_square = null
			active_piece = null
