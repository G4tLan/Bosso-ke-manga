extends Node2D
class_name Room

enum RoomType {
	DEFAULT, # 0
	BOSS_OFFICE,
	TOILET,
	KITCHEN,
	PARKING_LOT,
	BOARDROOM_A, #5
	BOARDROOM_B,
	OFFICE_A,
	OFFICE_B
}

@export var room_type: RoomType
@onready var waiting_area = $waiting_area
var activities: Array[RoomActivity]
var _waiting_queue: Array[NPC] = []

func _ready():
	# Gather child activities
	activities = []
	for child in get_children():
		if child is RoomActivity:
			activities.append(child)
	
func get_random_available_activity() -> RoomActivity:
	var available = activities.filter(func(a): return not a.is_occupied)
	if available.is_empty():
		return null
	
	var activity = available[randi() % available.size()]
	activity.is_occupied = true
	return activity
	
func add_npc_to_waiting_q(npc: NPC):
	_waiting_queue.push_back(npc)

func _on_body_entered(body: Node2D) -> void:
	if body is NPC:
		(body as NPC).set_room(self)

func _on_body_exited(body: Node2D) -> void:
	if body is NPC:
		if (body as NPC).exit_room():
			if !_waiting_queue.is_empty():
				var next_npc = _waiting_queue.pop_front()
				if next_npc != null:
					next_npc.attempt_to_do_activity()
