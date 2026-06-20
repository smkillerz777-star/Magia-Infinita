extends Control
var i = 0
func _process(deltall):
	if(Input.is_action_just_pressed("draw")):
		$lines.add_child(Line2D.new())
	elif(Input.is_action_pressed("draw")):
		$lines.get_child(i).add_point((get_global_mouse_position()))
	elif(Input.is_action_just_released("draw")):
		if(is_complete()):
			$lines.get_child(i).default_color = Color(0,0,0,1)
			i-=1
		i+=1
	else:
		pass
func is_complete():
	if($lines.get_child(i).points[0].distance_to($lines.get_child(i).points[$lines.get_child(i).points.size()-1])<5):
			print("complete by itself")
			return true


func _on_inventory_pressed() -> void:
	add_child(load("res://inventory.tscn").instantiate())
