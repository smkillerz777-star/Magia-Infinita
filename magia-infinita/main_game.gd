extends Control
var i = 0
var completed = 0
var first = true
var category = null
func _process(_delta):
	if(Input.is_action_just_pressed("draw")):
		category = null
		$lines.add_child(Line2D.new())
	elif(Input.is_action_pressed("draw")):
		$lines.get_child(i).add_point((get_global_mouse_position()))
		if($lines.get_child(i).points.size()>40):
			if(category==null):
				category = get_category($lines.get_child(i))
			else:
				if(get_category($lines.get_child(i)) != category):
					$lines.get_child(i).default_color = Color(0,0,0,1)
					category = null
					$lines.add_child(Line2D.new())
					i+=1

	elif(Input.is_action_just_released("draw")):
		if($lines.get_child(i).points.size()<30):
			$lines.get_child(i).queue_free()
		elif(is_complete()):
			var line = $lines.get_child(i)
			line.default_color = Color(0,0,0,1)
			#$lines.remove_child(line)
			#$completed.add_child(line)
			#add_child( normalization(resample(line),300))
			i+=1
		else:
			i+=1
	print(category)
	if($completed.get_child_count()>(completed+1)):
		if($completed.get_child_count()>=2):
			completed+=1
			for j in range(completed):
				print(compare($completed.get_child(j),$completed.get_child(completed)))

func is_complete():
	if($lines.get_child(i).points[0].distance_to($lines.get_child(i).points[$lines.get_child(i).points.size()-1])<5):
			return true


func _on_inventory_pressed() -> void:
	add_child(load("res://inventory.tscn").instantiate())

func activate(line: Line2D):
	get_child(0).visible = false
	get_child(1).visible = false
	get_child(2).visible = false
	get_child(3).visible = false
	get_child(4).visible = true
	var new = normalization(resample(line),360)
	get_child(4).get_child(4).add_child(new)
	get_child(4).get_child(4).get_child(0).position = Vector2(180,180)
	glow(get_child(4).get_child(3),get_child(4).get_child(4))

#takes a line as an input and make the total vectice count to number
func resample(line: Line2D,number = 32):
	var new_line : Line2D = Line2D.new()
	var temp : PackedVector2Array = PackedVector2Array()
	temp.resize(number)
	var path_len = path_length(line)
	var interval = path_len/(number-1)
	var d = 0.0
	var j = 1
	var k=1
	temp[0] = line.points[0]
	for point in line.points:
		if(j==line.points.size()):
			break
		var next_point = line.points[j]
		var distance = point.distance_to(next_point)
		if(distance == 0):
			j+=1
			continue
		d += distance
		while(d>interval):
			temp[k] = point.lerp(next_point,1-((d-interval)/distance))
			d-=interval
			k+=1
		j+=1
	temp[number-1] = line.points[0]
	new_line.points = temp
	return new_line

#normalizes the shape into a square of width multiplier with corners (0,0),(mutliplier,0),(multiplier,multiplier) and (0,multiplier)
func normalization(line,multiplier=1):
	return translate_to(change_size(line,multiplier))

func path_length(line):
	var path_len = 0.0
	var j = 1
	for point in line.points:
		if(j==line.points.size()):
			break
		path_len += point.distance_to(line.points[j])
		j+=1
	return path_len

func line_size(line):
	var max_x = -INF
	var max_y = -INF
	var min_x = INF
	var min_y = INF
	for point in line.points:
		max_x = max(max_x,point.x)
		max_y = max(max_y,point.y)
		min_x = min(min_x,point.x)
		min_y = min(min_y,point.y)
	return max(max_x-min_x,max_y-min_y)

#this function compares the two lines that are input and written they being same chances
func compare(line1,line2,does_size_matter=false,does_orientation_matter=false):
	var min_dis = 0.2 * 32
	var new_line1 = resample(line1)
	var new_line2 = resample(line2)
	if(not does_orientation_matter):
		new_line1 = rotate_to(new_line1)
		new_line2 = rotate_to(new_line2)
	if(not does_size_matter):
		new_line1 = normalization(new_line1)
		new_line2 = normalization(new_line2)
	else:
		new_line1 = translate_to(new_line1)
		new_line2 = translate_to(new_line2)
	var dis = 0.0
	for j in new_line1.points.size():
		dis += new_line1.points[j].distance_to(new_line2.points[j])
	print(dis)
	var prob = max(0.0,1.0-(dis/min_dis))
	return prob
		
func glow(mesh,subviewport):
	var mat = mesh.get_active_material(0)
	if mat:
		var viewport_texture = subviewport.get_texture()
		mat.albedo_texture = viewport_texture
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.emission_enabled = true
		mat.emission_texture = viewport_texture
		mat.emission = Color(0.0, 0.5, 1.0)
		mat.emission_energy_multiplier = 4

func mid_point(line):
	var max_x = -INF
	var max_y = -INF
	var min_x = INF
	var min_y = INF
	for point in line.points:
		max_x = max(max_x,point.x)
		max_y = max(max_y,point.y)
		min_x = min(min_x,point.x)
		min_y = min(min_y,point.y)
	return Vector2((max_x+min_x)/2,(max_y+min_y)/2)

func angle_bet(point1,point2):
	return atan2(point1.y-point2.y,point1.x-point2.x)

func rotate_to(line,deg=0):
	var about = mid_point(line)
	var temp = []
	var angle = deg_to_rad(deg)-angle_bet(line.points[0],about)-PI/2
	temp.resize(line.points.size())
	var j = 0
	for point in line.points:
		temp[j] = Vector2(about.x + (point.x - about.x)*cos(angle) - (point.y - about.y)*sin(angle),about.y + (point.x - about.x)*sin(angle) + (point.y - about.y)*cos(angle))
		j+=1
	var new_line = Line2D.new()
	new_line.points = temp
	return new_line

func is_dot(line):
	if(line_size(line)<15):
		return true
	return false

func line_circle(radius=50):
	var temp = []
	temp.resize(360)
	for j in range(0,360):
		temp[j] = Vector2(cos(deg_to_rad(j))*radius,sin(deg_to_rad(j))*radius)
	#temp[360] = temp[0]
	var line :Line2D = Line2D.new()
	line.points = temp
	return line

func is_circle(line):
	if(compare(line,line_circle())>0.7):
		return true
	return false
	

func change_size(line,multiplier):
	var shape_size = line_size(line)
	var temp = PackedVector2Array()
	var j = 0
	temp.resize(line.points.size())
	for point in line.points:
		temp[j].x = point.x/shape_size*multiplier
		temp[j].y = point.y/shape_size*multiplier
		j+=1
	var new_line = Line2D.new()
	new_line.points = temp
	return new_line

func translate_to(line):
	var min_x = INF
	var min_y = INF
	for point in line.points:
		min_x = min(min_x,point.x)
		min_y = min(min_y,point.y)
	var temp = PackedVector2Array()
	var j = 0
	temp.resize(line.points.size())
	for point in line.points:
		temp[j].x = (point.x - min_x)
		temp[j].y = (point.y - min_y)
		j+=1
	var new_line = Line2D.new()
	new_line.points = temp
	return new_line

func line_straight(angle=0,length=50):
	var temp = []
	temp.resize(2)
	temp[0] = Vector2(0,0)
	temp[1] = Vector2(sin(deg_to_rad(angle))*length,cos(deg_to_rad(angle))*length)
	var new_line = Line2D.new()
	new_line.points = temp
	return new_line

func is_straight(line):
	if(compare(line,line_straight())>0.85):
		return true
	return false

func get_category(line):
	if(is_straight(line)):
		return "line"
	elif(is_circle(line)):
		return "circle"
	return null