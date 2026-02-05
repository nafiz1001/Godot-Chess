class_name ChessPiece
extends Object

enum Type {KING, QUEEN, BISHOP, KNIGHT, ROOK, PAWN}
enum Colour {WHITE, BLACK}

var type: Type = Type.KING
var colour: Colour = Colour.WHITE

func valid_moves_1(square: Vector2i) -> Array[Array]:
	# Generates all possible moves for this piece from the given square
	# without considering other pieces on the board

	# an array of array of ChessMove
	var _moves: Array[Array] = []
	match type:
		Type.PAWN:
			var direction = -1 if colour == Colour.WHITE else 1
			var start_row = 6 if colour == Colour.WHITE else 1

			var forward_moves: Array[ChessMove] = []

			var forward_square = square + Vector2i(0, direction)
			if not ChessBoard.out_of_bounds(forward_square):
				forward_moves.append(ChessMove.new(forward_square, false, true))
			
			if square.y == start_row:
				var double_forward_square = square + Vector2i(0, 2 * direction)
				if not ChessBoard.out_of_bounds(double_forward_square):
					forward_moves.append(ChessMove.new(double_forward_square, false, true))
			
			if not forward_moves.is_empty():
				_moves.append(forward_moves)
			
			for diagonal_move in [-1, 1]:
				var attack_square = square + Vector2i(diagonal_move, direction)
				if not ChessBoard.out_of_bounds(attack_square):
					_moves.append([ChessMove.new(attack_square, true)])

		Type.ROOK:
			var directions = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
			for direction in directions:
				var path: Array[ChessMove] = []
				var current_square = square + direction
				while not ChessBoard.out_of_bounds(current_square):
					path.append(ChessMove.new(current_square, false))
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
					_moves.append([ChessMove.new(target_square, false)])

		Type.BISHOP:
			var directions = [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
			for direction in directions:
				var path: Array[ChessMove] = []
				var current_square = square + direction
				while not ChessBoard.out_of_bounds(current_square):
					path.append(ChessMove.new(current_square, false))
					current_square += direction
				if not path.is_empty():
					_moves.append(path)

		Type.QUEEN:
			var directions = [
				Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
				Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
			]
			for direction in directions:
				var path: Array[ChessMove] = []
				var current_square = square + direction
				while not ChessBoard.out_of_bounds(current_square):
					path.append(ChessMove.new(current_square, false))
					current_square += direction
				if not path.is_empty():
					_moves.append(path)

		Type.KING:
			var king_moves = [
				Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
				Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
			]
			for move in king_moves:
				var target_square = square + move
				if not ChessBoard.out_of_bounds(target_square):
					_moves.append([ChessMove.new(target_square, false)])

	return _moves
