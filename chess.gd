@tool
extends Node2D

var chess_board: ChessBoardNode = null
var chess_grid: Array[Array] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chess_board = load("res://chess_board.tscn").instantiate()
	add_child(chess_board)
