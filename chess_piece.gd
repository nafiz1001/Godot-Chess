@tool
class_name ChessPieceNode
extends Node2D

const SVG_SCALE = 2
const LENGTH = SVG_SCALE * 45

static var texture = preload("res://Chess_Pieces_Sprite.svg")
var atlas_texture = AtlasTexture.new()
var sprite = Sprite2D.new()

enum ChessPiece {KING, QUEEN, BISHOP, KNIGHT, ROOK, PAWN}
enum ChessColour {WHITE, BLACK}

var _piece: ChessPiece = ChessPiece.KING
var _colour: ChessColour = ChessColour.WHITE

@export var piece: ChessPiece:
	get():
		return _piece
	set(value):
		_piece = value
		update_atlas()

@export var colour: ChessColour:
	get():
		return _colour
	set(value):
		_colour = value
		update_atlas()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	atlas_texture.atlas = texture
	piece = _piece
	colour = _colour
	
	sprite.texture = atlas_texture
	add_child(sprite)

func update_atlas():
	atlas_texture.region = Rect2(LENGTH * piece, LENGTH * colour, LENGTH, LENGTH)
