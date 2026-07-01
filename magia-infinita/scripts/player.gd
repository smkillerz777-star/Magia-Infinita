extends CharacterBody3D
@export var speed = 5
@export var gravity = 15
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("forward")):
		velocity.z = -1
	if(Input.is_action_just_pressed("backward")):
		velocity.z = 1
	if(Input.is_action_just_released("forward") or Input.is_action_just_released("backward")):
		velocity.z = 0
	if(Input.is_action_just_pressed("left")):
		velocity.x = -1
	if(Input.is_action_just_pressed("right")):
		velocity.x = 1
	if(Input.is_action_just_released("left") or Input.is_action_just_released("right")):
		velocity.x = 0
	if(Input.is_action_just_pressed("jump")):
		velocity.y = speed
	if(position.y>0.0):
		velocity.y = velocity.y - gravity * delta
	if($view/ray.is_colliding()):
		print($view/ray.get_collision_point())
	var hori_vel = Vector2(velocity.x,velocity.z)
	hori_vel = hori_vel.normalized()* speed
	velocity = Vector3(hori_vel.x,velocity.y,hori_vel.y)
	move_and_slide()
