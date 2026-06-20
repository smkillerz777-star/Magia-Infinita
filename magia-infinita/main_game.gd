extends Node2D
var i = 0
func _process(deltall):
	if(Input.is_action_just_pressed("draw")):
		add_child(Line2D.new())
	elif(Input.is_action_pressed("draw")):
		get_child(i).add_point((get_global_mouse_position()))
	elif(Input.is_action_just_released("draw")):
		i+=1
	else:
		pass
