class_name Chess
extends Object
	
# index is from 0 to 63, starting from A8 to H1
var pieces: Array[ChessPiece] = []

func _init():
	for i in range(64):
		pieces.append(null)

func get_piece_at(square: Vector2i) -> ChessPiece:
	return pieces[ChessBoard.vec_to_index(square)]

func set_piece_at(square: Vector2i, piece: ChessPiece) -> void:
	pieces[ChessBoard.vec_to_index(square)] = piece

signal on_select_piece(square: Vector2i, piece: ChessPiece)
signal on_deselect_piece(square: Vector2i, piece: ChessPiece)
signal on_remove_piece(square: Vector2i, piece: ChessPiece)
signal on_place_piece(square: Vector2i, piece: ChessPiece)

var selected_square = null # Vector2i | null
var selected_piece: ChessPiece
func on_square_click(new_square: Vector2i):
	if selected_piece == null or selected_square == null:
		# there are no pieces currently selected
		if get_piece_at(new_square):
			selected_square = new_square
			selected_piece = get_piece_at(new_square)
			on_select_piece.emit(selected_square, selected_piece)
			# print("Selected a ",
			# 	ChessColour.keys()[selected_piece.colour],
			# 	" ",
			# 	ChessPieceType.keys()[selected_piece.type],
			# 	" at ", new_square
			# )
	else:
		# there is a piece currently selected
		var new_piece = get_piece_at(new_square)
		if new_piece != null and new_piece.colour == selected_piece.colour:
			# select different piece
			var temp_square = selected_square
			var temp_piece = selected_piece
			selected_square = null
			selected_piece = null
			on_deselect_piece.emit(temp_square, temp_piece)
			on_square_click(new_square) # recurse into selecting new piece
		else:
			# test that the move is valid
			var moves = selected_piece.valid_moves(selected_square, pieces)
			for path in moves:
				for move in path:
					if move == new_square:
						# The move is valid. Proceed with the move.
						var old_index = ChessBoard.vec_to_index(selected_square)						
						pieces[old_index] = null

						var new_index = ChessBoard.vec_to_index(new_square)
						
						var captured_piece = pieces[new_index]
						if captured_piece != null:
							pieces[new_index] = null
							on_remove_piece.emit(new_square, captured_piece)
						
						pieces[new_index] = selected_piece
						selected_square = null
						selected_piece = null
						on_place_piece.emit(new_square, pieces[new_index])
						return
			# deselect piece
			var temp_square = selected_square
			var temp_piece = selected_piece
			selected_square = null
			selected_piece = null
			on_deselect_piece.emit(temp_square, temp_piece)
