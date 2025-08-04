extends CharacterBody2D

class_name NPC

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var global_timer = get_node("/root/MainArea/Clock")

@export var speed := 80.0
@export var targetRoom: Room
var _last_direction := Vector2.DOWN
var _is_stationary = false
var _currentRoom: Room
var _currentActivity: RoomActivity
var targetActivity: RoomActivity

func _ready() -> void:
	global_timer.connect("quarter_hour_event", Callable(self, "_on_quarter_hour"))
	
	if targetRoom:
		_set_target_room(targetRoom)

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

func set_room(room: Room) -> void:
	# called when npc enters room area2D
	if targetRoom == null: return
	if targetRoom.room_type == room.room_type:
		_currentRoom = room
		targetRoom = null
		var available_activity = _currentRoom.get_random_available_activity()
		if available_activity == null:
			print("go to waiting ", _currentRoom.waiting_area.global_position)
			agent.target_position = _currentRoom.waiting_area.global_position
			_is_stationary = false
		else:
			print("set target activity ")
			_set_target_activity(available_activity)

func _set_target_room(room: Room) -> void:
	targetRoom = room
	agent.target_position = targetRoom.global_position
	_is_stationary = false
	collision_shape.disabled = true

func exit_room() -> void:
	# called when npc exits room area2D
	_currentRoom = null
	collision_shape.disabled = true
	
func set_activity(activity: RoomActivity) -> bool:
	# called when npc enteres activity area2D ➡️
	if targetActivity == null: return false

	if targetActivity.activity_type == activity.activity_type:
		_currentActivity = activity
		targetActivity = null
		return true
		#delay(2, func(): agent.target_position = Vector2(550, 250))
		
	return false

func _set_target_activity(activity: RoomActivity):
	targetActivity = activity
	agent.target_position = activity.global_position
	_is_stationary = false

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
			
func delay(seconds: float, callback: Callable) -> void:
	await get_tree().create_timer(seconds).timeout
	callback.call()

func _on_quarter_hour(time: float) -> void:
	print("Time is ",time)
