extends Node2D

class_name RoomActivity

var location: Vector2
@export var animation_key: String
var is_occupied: bool

func _ready() -> void:
	location = global_position
	is_occupied = false
