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
	chess_board.ready.connect(reset_cells)
	add_child(chess_board)

func reset_cells():
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
		var piece: ChessPieceNode = chess_piece_res.instantiate()
		piece.type = back_line_types[col]
		piece.colour = ChessColour.WHITE
		chess_board.find_child("Cells").find_child(ChessBoardNode.COLUMNS[col] + "8", false, false).add_child(piece)
	for col in range(8):
		var piece: ChessPieceNode = chess_piece_res.instantiate()
		piece.type = ChessPieceType.PAWN
		piece.colour = ChessColour.WHITE
		chess_board.find_child("Cells").find_child(ChessBoardNode.COLUMNS[col] + "7", false, false).add_child(piece)
	for col in range(8):
		var piece: ChessPieceNode = chess_piece_res.instantiate()
		piece.type = ChessPieceType.PAWN
		piece.colour = ChessColour.BLACK
		chess_board.find_child("Cells").find_child(ChessBoardNode.COLUMNS[col] + "2", false, false).add_child(piece)
	for col in range(8):
		var piece: ChessPieceNode = chess_piece_res.instantiate()
		piece.type = back_line_types[col]
		piece.colour = ChessColour.BLACK
		chess_board.find_child("Cells").find_child(ChessBoardNode.COLUMNS[col] + "1", false, false).add_child(piece)
