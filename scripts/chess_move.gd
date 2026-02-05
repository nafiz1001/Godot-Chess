class_name ChessMove
extends Object

var square: Vector2i
var capture_only: bool = false
var no_capture_only: bool = false

func _init(_square: Vector2i, _is_capture_only: bool = false, _no_capture_only: bool = false):
	square = _square
	capture_only = _is_capture_only
	no_capture_only = _no_capture_only
