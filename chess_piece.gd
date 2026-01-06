@tool
class_name ChessPieceNode
extends Node2D

const PADDING = 10
const LENGTH = ChessBoardNode.CELL_LENGTH - PADDING

static var textures: Dictionary[String, Texture2D] = {}

enum Type {KING, QUEEN, BISHOP, KNIGHT, ROOK, PAWN}
enum Colour {WHITE, BLACK}

var _type: Type = Type.KING
var _colour: Colour = Colour.WHITE

var cell: Node2D

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
	
	#$Area2D/CollisionShape2D.shape.size = Vector2(LENGTH, LENGTH)
	$Area2D/CollisionShape2D.debug_color = Color(randf(), randf(), randf(), 0.25)

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
