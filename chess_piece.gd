class_name ChessPiece
extends Object

enum Type {KING, QUEEN, BISHOP, KNIGHT, ROOK, PAWN}
enum Colour {WHITE, BLACK}

var type: Type = Type.KING
var colour: Colour = Colour.WHITE

# to help avoid infinite recursion when checking king valid_moves
static var controlled_king: ChessPiece = null
func valid_moves(square: Vector2i, chess_pieces: Array[ChessPiece]) -> Array[Array]:
	var _moves: Array[Array] = []
	match type:
		Type.PAWN:
			var direction = -1 if colour == Colour.WHITE else 1
			var start_row = 6 if colour == Colour.WHITE else 1

			var forward_moves: Array[Vector2i] = []

			var forward_square = square + Vector2i(0, direction)
			if not ChessBoard.out_of_bounds(forward_square):
				if not chess_pieces[ChessBoard.vec_to_index(forward_square)]:
					forward_moves.append(forward_square)

			var double_forward_square = square + Vector2i(0, 2 * direction)
			if not ChessBoard.out_of_bounds(double_forward_square):
				if square.y == start_row and not chess_pieces[ChessBoard.vec_to_index(double_forward_square)]:
					forward_moves.append(double_forward_square)
			
			if not forward_moves.is_empty():
				_moves.append(forward_moves)
			
			for horizontal_move in [-1, 1]:
				var attack_square = square + Vector2i(horizontal_move, direction)
				if not ChessBoard.out_of_bounds(attack_square):
					var attack_index = ChessBoard.vec_to_index(attack_square)
					if chess_pieces[attack_index] and chess_pieces[attack_index].colour != colour:
						_moves.append([attack_square])

		Type.ROOK:
			var directions = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
			for direction in directions:
				var path: Array[Vector2i] = []
				var current_square = square + direction
				while not ChessBoard.out_of_bounds(current_square):
					var index = ChessBoard.vec_to_index(current_square)
					if chess_pieces[index]:
						if chess_pieces[index].colour != colour:
							path.append(current_square)
						break # stop searching in this direction (while loop)
					else:
						path.append(current_square)
					current_square += direction
				if not path.is_empty():
					_moves.append(path)
		
		Type.KNIGHT:
			var knight_moves = [
				Vector2i(1, 2), Vector2i(2, 1), Vector2i(-1, 2), Vector2i(-2, 1),
				Vector2i(1, -2), Vector2i(2, -1), Vector2i(-1, -2), Vector2i(-2, -1)
			]
			for move in knight_moves:
				var target_square = square + move
				if not ChessBoard.out_of_bounds(target_square):
					var index = ChessBoard.vec_to_index(target_square)
					if not chess_pieces[index] or chess_pieces[index].colour != colour:
						_moves.append([target_square])

		Type.BISHOP:
			var directions = [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
			for direction in directions:
				var path: Array[Vector2i] = []
				var current_square = square + direction
				while not ChessBoard.out_of_bounds(current_square):
					var index = ChessBoard.vec_to_index(current_square)
					if chess_pieces[index]:
						if chess_pieces[index].colour != colour:
							path.append(current_square)
						break # stop searching in this direction (while loop)
					else:
						path.append(current_square)
					current_square += direction
				if not path.is_empty():
					_moves.append(path)

		Type.QUEEN:
			var directions = [
				Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
				Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
			]
			for direction in directions:
				var path: Array[Vector2i] = []
				var current_square = square + direction
				while not ChessBoard.out_of_bounds(current_square):
					var index = ChessBoard.vec_to_index(current_square)
					if chess_pieces[index]:
						if chess_pieces[index].colour != colour:
							path.append(current_square)
						break
					else:
						path.append(current_square)
					current_square += direction
				if not path.is_empty():
					_moves.append(path)

		Type.KING:
			if controlled_king == null:
				controlled_king = self

			var king_moves = [
				Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
				Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
			]
			for move in king_moves:
				var target_square = square + move
				if not ChessBoard.out_of_bounds(target_square):
					var index = ChessBoard.vec_to_index(target_square)
					if not chess_pieces[index] or chess_pieces[index].colour != colour:
						_moves.append([target_square])

			# Remove valid moves that would put king in check
			for index in range(chess_pieces.size()):
				var other_piece = chess_pieces[index]
				if other_piece and other_piece.colour != colour:
					if other_piece == controlled_king:
						# base case to avoid infinite recursion
						continue
					var other_piece_moves = other_piece.valid_moves(
						ChessBoard.index_to_vec(index),
						chess_pieces
					)
					for path in other_piece_moves:
						for attacked_square in path:
							for king_path in _moves.duplicate():
								# king only valid_moves one square at a time
								if king_path[0] == attacked_square:
									_moves.erase(king_path)
							
			controlled_king = null
			# Castling logic should be handled externally

	return _moves			

func is_in_danger(square: Vector2i, chess_pieces: Array[ChessPiece]) -> bool:
	for index in range(chess_pieces.size()):
		var other_piece = chess_pieces[index]
		if other_piece and other_piece.colour != colour:
			var other_piece_moves = other_piece.valid_moves(
				ChessBoard.index_to_vec(index),
				chess_pieces
			)
			for path in other_piece_moves:
				for attacked_square in path:
					if attacked_square == square:
						return true
	return false
