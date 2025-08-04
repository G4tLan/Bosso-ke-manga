extends Node2D

class_name RoomActivity

var location: Vector2
@export var animation_key: String
var is_occupied: bool

func _ready() -> void:
	location = global_position
	is_occupied = false

func _on_body_entered(body: Node2D) -> void:
	is_occupied = true
	if body is NPC:
		(body as NPC).set_activity(self)

func _on_body_exited(body: Node2D) -> void:
	is_occupied = false
	if body is NPC:
		(body as NPC).exit_activity()
