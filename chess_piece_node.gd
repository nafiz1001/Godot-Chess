@tool
class_name ChessPieceNode
extends Node2D

var data = ChessPiece.new()

@export var type: ChessPiece.Type:
	get():
		return data.type
	set(value):
		data.type = value
		update_texture()

@export var colour: ChessPiece.Colour:
	get():
		return data.colour
	set(value):
		data.colour = value
		update_texture()

# must be set before being added as a child
static var chess_board: ChessBoardNode

@export var PADDING = 10
var LENGTH: float:
	get():
		return (
			chess_board.GLOBAL_CELL_LENGTH
			if not Engine.is_editor_hint()
			else float(1024) / float(8)
		) - PADDING

static var textures: Dictionary[String, Texture2D] = {}

func _ready() -> void:
	type = data.type
	colour = data.colour
	update_texture()
	
	$Area2D/CollisionShape2D.shape.size = Vector2(LENGTH, LENGTH)
	$Area2D/CollisionShape2D.debug_color = Color(randf(), randf(), randf(), 0.25)

func update_texture():
	if textures.is_empty():
		for c in ChessPiece.Colour.keys():
			for t in ChessPiece.Type.keys():
				var filename = (c as String).substr(0, 1).to_lower() + "_" + (t as String).to_lower()
				textures[c + "-" + t] = load("res://Chess_Pieces/" + filename + ".png")

	$Sprite2D.texture = textures[ChessPiece.Colour.keys()[colour] + "-" + ChessPiece.Type.keys()[type]]
	$Sprite2D.scale = Vector2(LENGTH/$Sprite2D.texture.get_size().x, LENGTH/$Sprite2D.texture.get_size().y)


signal chess_piece_input_event(chess_piece_node: ChessPieceNode, event: InputEvent)
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	chess_piece_input_event.emit(self, event)
