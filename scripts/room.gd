extends Node2D
class_name Room

enum RoomType {
	TOILET,
	BOARDROOM_A,
	BOARDROOM_B,
	BOSS_OFFICE,
	CUBICLE,
	PARKING_LOT,
	KITCHEN,
	OFFICE_A,
	OFFICE_B
}

@export var room_type: RoomType
var activities: Array[RoomActivity]
var destination: Vector2

func _ready():

	# Set destination to this Room's position
	destination = global_position

	# Gather child activities
	activities = []
	for child in get_children():
		if child is RoomActivity:
			activities.append(child)
			
	var t = 90;
	
func get_random_available_activity() -> RoomActivity:
	var available = activities.filter(func(a): return not a.is_occupied)
	if available.is_empty():
		return null  # Or handle fallback logic
	return available[randi() % available.size()]

func _on_body_entered(body: Node2D) -> void:
	if body is NPC:
		(body as NPC).set_room(self)

func _on_body_exited(body: Node2D) -> void:
	if body is NPC:
		(body as NPC).exit_room()
