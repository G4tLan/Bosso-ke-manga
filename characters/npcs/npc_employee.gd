extends CharacterBody2D

class_name NPC

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var global_timer = get_node("/root/MainArea/Clock")

@export var speed := 40.0
@export var defaultRoom: Room
@export var schedule: Schedule
var _last_direction := Vector2.DOWN
var _is_stationary = false
var _currentRoom: Room
var _targetRoom: Room
var _currentActivity: RoomActivity
var _targetActivity: RoomActivity
var _is_in_waiting_area: bool = false #TODO: reset when setting a new task

func _ready() -> void:
	global_timer.connect("quarter_hour_event", Callable(self, "_on_quarter_hour"))
	
	if _targetRoom:
		_set_target_room(_targetRoom)

func _physics_process(delta: float) -> void:
	if _is_stationary:
		return
	
	var next_point = agent.get_next_path_position()
	var direction = (next_point - global_position).normalized()
	agent.velocity = (direction * speed)

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	if velocity.length() > 0:
		_last_direction = velocity.normalized()
		update_walk_animation()
	else:
		update_idle_animation()
	move_and_slide() # Replace with function body.

func _on_navigation_agent_2d_target_reached() -> void:
	pass

func _on_navigation_agent_2d_navigation_finished() -> void:
	collision_shape.disabled = false
	velocity = Vector2.ZERO
	_is_stationary = true

#func _draw() -> void:
	#var radius = agent.radius
	#draw_circle(Vector2.ZERO, radius, Color(1, 0, 0, 0.3))


#my functions

func set_room(room: Room) -> bool:
	# called when npc enters room area2D ➡️
	if _targetRoom == null: return false
	if _targetRoom.room_type == room.room_type:
		_currentRoom = room
		_targetRoom = null
		attempt_to_do_activity()
		return true

	return false

func _set_target_room(room: Room) -> void:
	_targetRoom = room
	agent.target_position = _targetRoom.global_position
	_is_stationary = false
	collision_shape.disabled = true

func exit_room() -> bool:
	# called when npc exits room area2D ➡️
	if _currentRoom == null || _is_in_waiting_area: return false;

	_currentRoom = null
	collision_shape.disabled = true
	return true

func set_activity(activity: RoomActivity) -> bool:
	# called when npc enteres activity area2D ➡️
	if _targetActivity == null: return false

	if _targetActivity.activity_type == activity.activity_type:
		_is_in_waiting_area = false
		_currentActivity = activity
		_targetActivity = null
		_delay(randi() % (30 - 5 + 1) + 5, Callable(self, "_go_to_location"), [Vector2(540,randi() % (300 - 30 + 1) + 30)])
		return true

	return false

func _set_target_activity(activity: RoomActivity):
	_targetActivity = activity
	_is_in_waiting_area = false
	agent.target_position = activity.global_position
	_is_stationary = false
	
func attempt_to_do_activity():
	if _currentRoom == null: return
	var available_activity = _currentRoom.get_random_available_activity()
	if available_activity == null:
		print("go to waiting ", _currentRoom.waiting_area.global_position)
		_is_in_waiting_area = true
		_currentRoom.add_npc_to_waiting_q(self)
		_go_to_location(_currentRoom.waiting_area.global_position)
	else:
		print("set target activity ")
		_set_target_activity(available_activity)

func exit_activity() -> bool:
	# called when npc exits activity area2D ➡️
	if _currentActivity == null: return false

	_currentActivity = null
	return true

func update_walk_animation():
	if abs(_last_direction.x) > abs(_last_direction.y):
		if _last_direction.x > 0:
			animated_sprite.play("walk_right")
		else:
			animated_sprite.play("walk_left")
	else:
		if _last_direction.y > 0:
			animated_sprite.play("walk_down")
		else:
			animated_sprite.play("walk_up")

func update_idle_animation():
	if abs(_last_direction.x) > abs(_last_direction.y):
		if _last_direction.x > 0:
			animated_sprite.play("idle_right")
		else:
			animated_sprite.play("idle_left")
	else:
		if _last_direction.y > 0:
			animated_sprite.play("idle_down")
		else:
			animated_sprite.play("idle_up")

func _go_to_location(location: Vector2):
		agent.target_position = location
		_is_stationary = false

func _delay(seconds: float, callback: Callable, args: Array = []) -> void:
	await get_tree().create_timer(seconds).timeout
	callback.callv(args)

func _on_quarter_hour(time: float) -> void:
	print("Time is ",time)
