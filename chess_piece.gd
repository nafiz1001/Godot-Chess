@tool
class_name ChessPieceNode
extends Node2D

# must be set before being added as a child
var chess_board: ChessBoardNode = null

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

var square: Vector2i

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

static func is_move_valid(piece: ChessPieceNode, from: Vector2i, existing_piece: ChessPieceNode, to: Vector2i):
	# white is assumed to be from the bottom
	# black is assumed to be from the top

	if existing_piece != null and existing_piece.colour == piece.colour:
		return false

	var delta = to - from
	match piece.type:
		Type.PAWN:
			var direction = -1 if piece.colour == Colour.WHITE else 1
			# move forward
			if delta.x == 0:
				if existing_piece != null:
					return false
				if delta.y == direction:
					return true
				if (piece.colour == Colour.WHITE and from.y == 6) or (piece.colour == Colour.BLACK and from.y == 1):
					if delta.y == 2 * direction:
						return true
			# capture diagonally
			elif abs(delta.x) == 1 and delta.y == direction:
				if existing_piece != null and existing_piece.colour != piece.colour:
					return true
			return false
		Type.ROOK:
			return delta.x == 0 or delta.y == 0
		Type.KNIGHT:
			return (abs(delta.x) == 2 and abs(delta.y) == 1) or (abs(delta.x) == 1 and abs(delta.y) == 2)
		Type.BISHOP:
			return abs(delta.x) == abs(delta.y)
		Type.QUEEN:
			return delta.x == 0 or delta.y == 0 or abs(delta.x) == abs(delta.y)
		Type.KING:
			return abs(delta.x) <= 1 and abs(delta.y) <= 1
	return false

func update_texture():
	if textures.is_empty():
		for c in Colour.keys():
			for t in Type.keys():
				var filename = (c as String).substr(0, 1).to_lower() + "_" + (t as String).to_lower()
				textures[c + "-" + t] = load("res://Chess_Pieces/" + filename + ".png")

	$Sprite2D.texture = textures[Colour.keys()[colour] + "-" + Type.keys()[type]]
	$Sprite2D.scale = Vector2(LENGTH/$Sprite2D.texture.get_size().x, LENGTH/$Sprite2D.texture.get_size().y)

signal chess_piece_input_event(chess_piece_node: ChessPieceNode, event: InputEvent)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	chess_piece_input_event.emit(self, event)
