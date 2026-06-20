extends Control
var i = 0
func _ready() -> void:
	var line = Line2D.new()
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
			#resample($lines.get_child(i))
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
	get_child(0).visible = false
	get_child(1).visible = false
	get_child(2).visible = false
	get_child(3).visible = true
	get_child(3).get_child(2).visible = true
	var new = normalization(resample(line,15),300)
	get_child(3).get_child(2).get_child(0).add_child(new)

#takes a line as an input and make the total vectice count to number
func resample(line: Line2D,number):
	var new_line : Line2D = Line2D.new()
	var temp : PackedVector2Array = PackedVector2Array()
	var path_length = 0.0
	var j = 1
	for point in line.points:
		if(j==line.points.size()):
			path_length += point.distance_to(line.points[0])
			break
		path_length += point.distance_to(line.points[j])
		j+=1
	temp.resize(number)
	var dis = path_length/number
	var d = 0.0
	j = 1
	var k=1
	temp[0] = line.points[0]
	for point in line.points:
		if(j==line.points.size()):
			break
		d += point.distance_to(line.points[j])
		if(d>dis):
			temp[k] = point
			k+=1
			d=d-dis
		j+=1
	temp.append(line.points[0])
	new_line.points = temp
	return new_line

#normalizes the shape into a square of width 1 with corners (0,0),(1,0),(1,1) and (0,1)
func normalization(line,multiplier):
	var max_x = -INF
	var max_y = -INF
	var min_x = INF
	var min_y = INF
	for point in line.points:
		max_x = max(max_x,point.x)
		max_y = max(max_y,point.y)
		min_x = min(min_x,point.x)
		min_y = min(min_y,point.y)
	var shape_size : float = max(max_x-min_x,max_y-min_y)
	var temp = PackedVector2Array()
	var j = 0
	temp.resize(line.points.size())
	for point in line.points:
		temp[j].x = (point.x - min_x)/shape_size*multiplier
		temp[j].y = (point.y - min_y)/shape_size*multiplier
		j+=1
	var new_line = Line2D.new()
	new_line.points = temp
	return new_line