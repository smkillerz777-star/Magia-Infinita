extends Control
var i = 0
func _process(_delta):
	if(Input.is_action_just_pressed("draw")):
		$lines.add_child(Line2D.new())
	elif(Input.is_action_pressed("draw")):
		$lines.get_child(i).add_point((get_global_mouse_position()))
	elif(Input.is_action_just_released("draw")):
		if($lines.get_child(i).points.size()<30):
			$lines.get_child(i).queue_free()
		elif(is_complete()):
			$lines.get_child(i).default_color = Color(0,0,0,1)
			activate($lines.get_child(i))
			i+=1
		else:
			i+=1
	else:
		pass
func is_complete():
	if($lines.get_child(i).points[0].distance_to($lines.get_child(i).points[$lines.get_child(i).points.size()-1])<5):
			return true


func _on_inventory_pressed() -> void:
	add_child(load("res://inventory.tscn").instantiate())

func activate(line: Line2D):
	$lines.remove_child(line)
	get_child(0).visible = false
	get_child(1).visible = false
	get_child(2).visible = false
	get_child(3).visible = true
	get_child(3).get_child(2).visible = true
	get_child(3).get_child(2).get_child(0).add_child(line)
