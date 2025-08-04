extends Node2D

class_name RoomActivity

enum ActivityType {
	ACTIVITY_A,
	ACTIVITY_B,
	ACTIVITY_C,
	ACTIVITY_D,
	ACTIVITY_E,
	ACTIVITY_F,
	ACTIVITY_G,
	ACTIVITY_H,
	ACTIVITY_I,
}

@export var animation_key: String
@export var activity_type: ActivityType
var is_occupied: bool

func _ready() -> void:
	is_occupied = false

func _on_body_entered(body: Node2D) -> void:
	if body is NPC:
		if (body as NPC).set_activity(self):
			print("activity entered -> occupied")
			is_occupied = true

func _on_body_exited(body: Node2D) -> void:
	if body is NPC:
		if (body as NPC).exit_activity():
			print("activity exited -> unoccupied")
			is_occupied = false
