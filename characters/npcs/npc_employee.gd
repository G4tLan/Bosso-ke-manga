extends CharacterBody2D

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var global_timer = get_node("/root/MainArea/Clock")

@export var speed := 80.0
@export var destination: Node2D = null
var last_direction := Vector2.DOWN
func _ready() -> void:
	global_timer.connect("quarter_hour_event", Callable(self, "_on_quarter_hour"))
	if destination:
		agent.target_position = destination.global_position

func _physics_process(delta: float) -> void:
	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	
	var next_point = agent.get_next_path_position()
	var direction = (next_point - global_position).normalized()
	agent.velocity = (direction * speed)

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	if velocity.length() > 0:
		last_direction = velocity.normalized()
		update_walk_animation()
	else:
		update_idle_animation()
	move_and_slide() # Replace with function body.

func _draw() -> void:
	var radius = agent.radius
	draw_circle(Vector2.ZERO, radius, Color(1, 0, 0, 0.3))



#my functions

func update_walk_animation():
	if abs(last_direction.x) > abs(last_direction.y):
		if last_direction.x > 0:
			animated_sprite.play("walk_right")
		else:
			animated_sprite.play("walk_left")
	else:
		if last_direction.y > 0:
			animated_sprite.play("walk_down")
		else:
			animated_sprite.play("walk_up")

func update_idle_animation():
	if abs(last_direction.x) > abs(last_direction.y):
		if last_direction.x > 0:
			animated_sprite.play("idle_right")
		else:
			animated_sprite.play("idle_left")
	else:
		if last_direction.y > 0:
			animated_sprite.play("idle_down")
		else:
			animated_sprite.play("idle_up")

func _on_quarter_hour(time: float) -> void:
	print("Time is ",time)
