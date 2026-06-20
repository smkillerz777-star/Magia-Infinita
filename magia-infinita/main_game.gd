extends Node2D
var i = 1
func _process(deltall):
	if(Input.is_action_just_pressed("draw")):
		add_child(Line2D.new())
	elif(Input.is_action_pressed("draw")):
		get_child(i).add_point((get_global_mouse_position()))
	elif(Input.is_action_just_released("draw")):
		if(is_complete()):
			get_child(i).queue_free()
			i-=1
		i+=1
	else:
		print(get_children().size())
func is_complete():
	if(get_child(i).points[0].distance_to(get_child(i).points[get_child(i).points.size()-1])<5):
			print("complete by itself")
			return true
