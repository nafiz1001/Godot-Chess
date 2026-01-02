extends Node2D

var chess_board: ChessBoardNode
var chess_piece: ChessPieceNode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chess_board = load("res://chess_board.tscn").instantiate()
