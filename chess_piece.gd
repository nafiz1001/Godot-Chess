@tool
class_name ChessPieceNode
extends Node2D

const SVG_SCALE = 2
const LENGTH = SVG_SCALE * 45

static var texture = preload("res://Chess_Pieces_Sprite.svg")
var atlas_texture = AtlasTexture.new()
var sprite = Sprite2D.new()

enum Type {KING, QUEEN, BISHOP, KNIGHT, ROOK, PAWN}
enum Colour {WHITE, BLACK}

var _type: Type = Type.KING
var _colour: Colour = Colour.WHITE

var square: Vector2i # (col, row)

@export var type: Type:
	get():
		return _type
	set(value):
		_type = value
		update_atlas()

@export var colour: Colour:
	get():
		return _colour
	set(value):
		_colour = value
		update_atlas()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	atlas_texture.atlas = texture
	type = _type
	colour = _colour
	
	sprite.texture = atlas_texture
	add_child(sprite)
	
	$Area2D/CollisionShape2D.shape.size = Vector2(LENGTH, LENGTH)
	$Area2D/CollisionShape2D.debug_color = Color(randf(), randf(), randf(), 0.25)

func update_atlas():
	atlas_texture.region = Rect2(LENGTH * type, LENGTH * colour, LENGTH, LENGTH)

signal chess_piece_input_event(chess_piece_node: ChessPieceNode, event: InputEvent)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	chess_piece_input_event.emit(self, event)
