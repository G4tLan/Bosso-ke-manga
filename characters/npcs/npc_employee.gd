extends CharacterBody2D

class_name NPC

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var global_timer = get_node("/root/MainArea/Clock")

@export var speed := 80.0
@export var destination: Node2D = null
var _last_direction := Vector2.DOWN
var _is_stationary = false
var _currentRoom: Room
var _currentActivity: RoomActivity

func _ready() -> void:
	global_timer.connect("quarter_hour_event", Callable(self, "_on_quarter_hour"))
	
	if destination:
		collision_shape.disabled = true
		_is_stationary = false
		agent.target_position = destination.global_position

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
	collision_shape.disabled = false

func _on_navigation_agent_2d_navigation_finished() -> void:
	velocity = Vector2.ZERO
	_is_stationary = true

#func _draw() -> void:
	#var radius = agent.radius
	#draw_circle(Vector2.ZERO, radius, Color(1, 0, 0, 0.3))


#my functions

func set_room(room: Room) -> void:
	if _is_stationary:
		_currentRoom = room

		var available_activity = _currentRoom.get_random_available_activity()
		if available_activity == null:
			return
			#get the current room waiting area location

		agent.target_position = available_activity.location
		collision_shape.disabled = true
		_is_stationary = false

func exit_room() -> void:
	_currentRoom = null
	
func set_activity(activity: RoomActivity) -> void:
	if _is_stationary:
		_currentActivity = activity
		#to test delay for 5 secs and leave activity

func exit_activity() -> void:
	_currentRoom = null

func update_walk_animation():
	#print("walk animation")
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

func _on_quarter_hour(time: float) -> void:
	print("Time is ",time)
