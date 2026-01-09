@tool
class_name ChessPieceNode
extends Node2D

# must be set before being added as a child
var chess_board: ChessBoardNode

@export var PADDING = 10
var LENGTH: float:
	get():
		return (
			chess_board.GLOBAL_CELL_LENGTH
			if not Engine.is_editor_hint()
			else float(1024) / float(8)
		) - PADDING

static var textures: Dictionary[String, Texture2D] = {}

enum Type {KING, QUEEN, BISHOP, KNIGHT, ROOK, PAWN}
enum Colour {WHITE, BLACK}

var _type: Type = Type.KING
var _colour: Colour = Colour.WHITE

@export var type: Type:
	get():
		return _type
	set(value):
		_type = value
		update_texture()

@export var colour: Colour:
	get():
		return _colour
	set(value):
		_colour = value
		update_texture()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = _type
	colour = _colour
	update_texture()
	
	$Area2D/CollisionShape2D.shape.size = Vector2(LENGTH, LENGTH)
	$Area2D/CollisionShape2D.debug_color = Color(randf(), randf(), randf(), 0.25)

func update_texture():
	if textures.is_empty():
		for c in Colour.keys():
			for t in Type.keys():
				var filename = (c as String).substr(0, 1).to_lower() + "_" + (t as String).to_lower()
				textures[c + "-" + t] = load("res://Chess_Pieces/" + filename + ".png")

	$Sprite2D.texture = textures[Colour.keys()[colour] + "-" + Type.keys()[type]]
	$Sprite2D.scale = Vector2(LENGTH/$Sprite2D.texture.get_size().x, LENGTH/$Sprite2D.texture.get_size().y)

# to avoid infinite recursion when checking king moves
var controlled_king: ChessPieceNode = null
func moves(square: Vector2i, active_chess_pieces: Dictionary[String, ChessPieceNode]) -> Array[Array]:
	var _moves: Array[Array] = []
	match type:
		Type.PAWN:
			var direction = -1 if colour == Colour.WHITE else 1
			var start_row = 6 if colour == Colour.WHITE else 1

			var forward_moves: Array[Vector2i] = []
			var forward_square = square + Vector2i(0, direction)
			if not ChessBoardNode.out_of_bounds(forward_square):
				var forward_coords = ChessBoardNode.vec_to_coords(forward_square)
				if not active_chess_pieces.has(forward_coords):
					forward_moves.append(forward_square)

			var double_forward_square = square + Vector2i(0, 2 * direction)
			if not ChessBoardNode.out_of_bounds(double_forward_square):
				var double_forward_coords = ChessBoardNode.vec_to_coords(double_forward_square)
				if square.y == start_row and not active_chess_pieces.has(double_forward_coords):
					forward_moves.append(double_forward_square)
			
			for horizontal_move in [-1, 1]:
				var attack_square = square + Vector2i(horizontal_move, direction)
				if not ChessBoardNode.out_of_bounds(attack_square):
					var attack_coords = ChessBoardNode.vec_to_coords(attack_square)
					if active_chess_pieces.has(attack_coords) and active_chess_pieces[attack_coords].colour != colour:
						_moves.append([attack_square])

		Type.ROOK:
			var directions = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
			for direction in directions:
				var path: Array[Vector2i] = []
				var current_square = square + direction
				while not ChessBoardNode.out_of_bounds(current_square):
					var coords = ChessBoardNode.vec_to_coords(current_square)
					if active_chess_pieces.has(coords):
						if active_chess_pieces[coords].colour != colour:
							path.append(current_square)
						break
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
				if not ChessBoardNode.out_of_bounds(target_square):
					var coords = ChessBoardNode.vec_to_coords(target_square)
					if not active_chess_pieces.has(coords) or active_chess_pieces[coords].colour != colour:
						_moves.append([target_square])

		Type.BISHOP:
			var directions = [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
			for direction in directions:
				var path: Array[Vector2i] = []
				var current_square = square + direction
				while not ChessBoardNode.out_of_bounds(current_square):
					var coords = ChessBoardNode.vec_to_coords(current_square)
					if active_chess_pieces.has(coords):
						if active_chess_pieces[coords].colour != colour:
							path.append(current_square)
						break
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
				while not ChessBoardNode.out_of_bounds(current_square):
					var coords = ChessBoardNode.vec_to_coords(current_square)
					if active_chess_pieces.has(coords):
						if active_chess_pieces[coords].colour != colour:
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
				if not ChessBoardNode.out_of_bounds(target_square):
					var coords = ChessBoardNode.vec_to_coords(target_square)
					if not active_chess_pieces.has(coords) or active_chess_pieces[coords].colour != colour:
						_moves.append([target_square])

			# Remove moves that would put king in check
			for coords in active_chess_pieces.keys():
				var other_piece = active_chess_pieces[coords]
				if other_piece.colour != colour:
					if other_piece.type == Type.KING and other_piece == controlled_king:
						# base case to avoid infinite recursion
						continue
					var other_piece_moves = other_piece.moves(
						ChessBoardNode.coords_to_vec(coords),
						active_chess_pieces
					)
					for path in other_piece_moves:
						for attacked_square in path:
							for king_path in _moves.duplicate():
								# king only moves one square at a time
								if king_path[0] == attacked_square:
									_moves.erase(king_path)
							
			controlled_king = null
			# Castling logic should be handled externally

	return _moves			

signal chess_piece_input_event(chess_piece_node: ChessPieceNode, event: InputEvent)
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	chess_piece_input_event.emit(self, event)
