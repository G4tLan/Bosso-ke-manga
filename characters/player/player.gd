extends CharacterBody2D

@export var speed := 200.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var last_direction := Vector2.DOWN

func _physics_process(delta):
	var input_dir = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	velocity = input_dir  * speed;
	if velocity.length() > 0:
		last_direction = velocity.normalized()
		update_walk_animation()
	else:
		update_idle_animation()
	# Apply movement
	move_and_slide()


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
