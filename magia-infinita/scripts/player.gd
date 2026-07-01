extends CharacterBody3D
@export var speed = 5
@export var gravity = 15
@export var acceleration: float = 10.0
@export var friction: float = 150.0
@export var jump_velocity: float = 4.5
func _process(delta: float) -> void:
	var direction = Vector3.ZERO
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	if direction != Vector3.ZERO:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction * delta)
		velocity.z = lerp(velocity.z, 0.0, friction * delta)
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
	else:
		velocity.y -= gravity * delta
	if($view/ray.is_colliding()):
		pass#$view/ray.get_collision_point()
	var hori_vel = Vector2(velocity.x,velocity.z)
	hori_vel = hori_vel.normalized()* speed
	velocity = Vector3(hori_vel.x,velocity.y,hori_vel.y)
	move_and_slide()
