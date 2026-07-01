extends CharacterBody3D
@export var speed = 5
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
        velocity.y = 1
    velocity = velocity.normalized()*speed
    move_and_slide()