@tool
class_name ChessNode
extends Node2D

var chess: Chess = Chess.new()

const chess_board_scene = preload("res://chess_board.tscn")
const chess_piece_res = preload("res://chess_piece.tscn")

var chess_board: ChessBoardNode

# key is coordinates
var active_chess_pieces: Dictionary[ChessPiece, ChessPieceNode] = {}

func _ready() -> void:
	chess_board = chess_board_scene.instantiate() as ChessBoardNode
	chess_board.name = "Chess_Board"
	add_child(chess_board)
	
	ChessPieceNode.chess_board = chess_board

	chess_board.on_square_click.connect(chess.on_square_click)
	chess.on_select_piece.connect(on_select_piece)
	chess.on_deselect_piece.connect(on_deselect_piece)
	chess.on_remove_piece.connect(on_remove_piece)
	chess.on_place_piece.connect(on_place_piece)
	
	var back_line_types = [
		ChessPiece.Type.ROOK,
		ChessPiece.Type.KNIGHT,
		ChessPiece.Type.BISHOP,
		ChessPiece.Type.QUEEN,
		ChessPiece.Type.KING,
		ChessPiece.Type.BISHOP,
		ChessPiece.Type.KNIGHT,
		ChessPiece.Type.ROOK
	]
	for col in range(8):
		initialize_piece(back_line_types[col], ChessPiece.Colour.BLACK, col, 0)
		initialize_piece(ChessPiece.Type.PAWN, ChessPiece.Colour.BLACK, col, 1)
		initialize_piece(ChessPiece.Type.PAWN, ChessPiece.Colour.WHITE, col, 6)
		initialize_piece(back_line_types[col], ChessPiece.Colour.WHITE, col, 7)

func initialize_piece(type: ChessPiece.Type, colour: ChessPiece.Colour, col: int, row: int):
	var square = Vector2i(col, row)
	var col_name = ChessBoard.COLUMNS[col]
	#var row_name = ChessBoardNode.ROWS[row]
	var piece = chess_piece_res.instantiate() as ChessPieceNode

	piece.type = type
	piece.colour = colour
	piece.global_position = chess_board.square_to_global_position(square)
	piece.name = ChessPiece.Colour.keys()[colour] + "-" + ChessPiece.Type.keys()[type] + "-" + col_name
	piece.z_index = 1
	# don't handle input event of individual chess piece, instead handle event on each square
	#piece.chess_piece_input_event.connect(chess_piece_input_event)
	$Pieces.add_child(piece)
	
	active_chess_pieces[piece.data] = piece
	chess.set_piece_at(square, piece.data)
	
	return piece

func on_select_piece(active_square: Vector2i, piece: ChessPiece):
	var active_piece = active_chess_pieces[piece]

	active_piece.modulate = Color(0.8, 0.8, 1, 1)
	print("Selected a ",
		ChessPiece.Colour.keys()[active_piece.colour],
		" ",
		ChessPiece.Type.keys()[active_piece.type],
		" at ", active_square
	)
	for child in $Hints.get_children():
		child.queue_free()

	for path in chess.valid_moves_2(active_square):
		for _move_object in path:
			var move_object: ChessMove = _move_object

			# highlight possible moves
			var highlight = MeshInstance2D.new()
			var plane_mesh = QuadMesh.new()
			plane_mesh.size = Vector2(chess_board.GLOBAL_CELL_LENGTH - active_piece.PADDING, chess_board.GLOBAL_CELL_LENGTH - active_piece.PADDING)
			highlight.mesh = plane_mesh
			highlight.position = chess_board.square_to_global_position(move_object.square)
			highlight.modulate = Color(1, 0, 0, 0.25) if chess.get_piece_at(move_object.square) else Color(0, 1, 0, 0.25)
			highlight.z_index = 1
			$Hints.add_child(highlight)

func on_deselect_piece(_active_square: Vector2i, piece: ChessPiece):
	var deselected_piece = active_chess_pieces[piece]
	deselected_piece.modulate = Color(1, 1, 1, 1)
	for child in $Hints.get_children():
		child.queue_free()

func on_remove_piece(square: Vector2i, piece: ChessPiece):
	var removed_piece = active_chess_pieces[piece]
	removed_piece.visible = false
	active_chess_pieces.erase(piece)
	print("Removed a ",
		ChessPiece.Colour.keys()[removed_piece.colour],
		" ",
		ChessPiece.Type.keys()[removed_piece.type],
		" at ", square
	)

func on_place_piece(square: Vector2i, piece: ChessPiece):
	var placed_piece = active_chess_pieces[piece]
	placed_piece.global_position = chess_board.square_to_global_position(square)
	print("Placed a ",
		ChessPiece.Colour.keys()[placed_piece.colour],
		" ",
		ChessPiece.Type.keys()[placed_piece.type],
		" at ", square
	)
	placed_piece.modulate = Color(1, 1, 1, 1)
	for child in $Hints.get_children():
		child.queue_free()
