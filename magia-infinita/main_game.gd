extends Control
var i = 0
var completed = 0
var first = true
func _process(_delta):
	if(get_global_mouse_position().y<670):
		if(Input.is_action_just_pressed("draw")):
			$lines.add_child(customLine2D.new())
		elif(Input.is_action_pressed("draw")):
			$lines.get_child(i).add_point((get_global_mouse_position()))
			#if(is_complete($lines.get_child(i)) and $lines.get_child(i).points.size()>50 and not is_dot($lines.get_child(i))):
				#$lines.get_child(i).category = get_category($lines.get_child(i))
				#create_new($lines.get_child(i))
				#$lines.add_child(customLine2D.new())
			#elif($lines.get_child(i).points.size()>40 and line_size($lines.get_child(i))>30):
				#if($lines.get_child(i).category == "default"):
					#$lines.get_child(i).category = get_category($lines.get_child(i))
				#else:
					#if(get_category($lines.get_child(i))=="circle" and $lines.get_child(i).category=="partial circle"):
						#$lines.get_child(i).category="circle"
					#elif((get_category($lines.get_child(i)) != $lines.get_child(i).category)):
						#create_new($lines.get_child(i))
						#$lines.add_child(customLine2D.new())

		elif(Input.is_action_just_released("draw")):
			var line = $lines.get_child(i)
			if($lines.get_child(i).points.size()<30):
				$lines.get_child(i).queue_free()
			#elif(is_dot(line)):
				#line.category = "dot"
				#create_new(line)
			else:
				#line.category = get_category(line)
				create_new(line)

func is_complete(line):
	if(line.points[0].distance_to(line.points[line.points.size()-1])<5):
			return true

func create_new(_line):
	#print(line.category)
	#line.default_color = Color(0,0,0,1)
	#if(line.category=="default"):
		#line.queue_free()
		#i-=1
	i+=1
func _on_inventory_pressed() -> void:
	add_child(load("res://inventory.tscn").instantiate())

func activate(line: customLine2D):
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
func resample(line: customLine2D,number = 32):
	var new_line : customLine2D = customLine2D.new()
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

func lines_size(lines):
	var max_x = -INF
	var max_y = -INF
	var min_x = INF
	var min_y = INF
	for line in lines:
		for point in line.points:
			max_x = max(max_x,point.x)
			max_y = max(max_y,point.y)
			min_x = min(min_x,point.x)
			min_y = min(min_y,point.y)
	return Vector2(max_x,max_y).distance_to(Vector2(min_x,min_y))

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
	var new_line = customLine2D.new()
	new_line.points = temp
	return new_line

func is_dot(line):
	if(line_size(line)<15):
		return true
	return false

func line_circle(radius=50):
	var temp = []
	temp.resize(361)
	for j in range(0,360):
		temp[j] = Vector2(cos(deg_to_rad(j))*radius,sin(deg_to_rad(j))*radius)
	temp[360] = temp[0]
	var line :customLine2D = customLine2D.new()
	line.points = temp
	return line

func is_circle(line,prob=0.75):
	if(compare(line,line_circle())>prob):
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
	var new_line = customLine2D.new()
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
	var new_line = customLine2D.new()
	new_line.points = temp
	return new_line

func line_straight(angle=0,length=50):
	var temp = []
	temp.resize(2)
	temp[0] = Vector2(0,0)
	temp[1] = Vector2(sin(deg_to_rad(angle))*length,cos(deg_to_rad(angle))*length)
	var new_line = customLine2D.new()
	new_line.points = temp
	return new_line

func line_straight_twice(angle=0,length=50):
	var temp = []
	temp.resize(3)
	temp[0] = Vector2(0,0)
	temp[1] = Vector2(sin(deg_to_rad(angle))*length,cos(deg_to_rad(angle))*length)
	temp[2] = Vector2(0,0)
	var new_line = customLine2D.new()
	new_line.points = temp
	return new_line

func is_straight(line):
	if(compare(line,line_straight())>0.93 or compare(line,line_straight_twice())>0.93):
		return true
	return false

func get_category(line):
	if(is_straight(line)):
		return "line"
	elif(is_circle(line) and is_complete(line)):
			return "circle"
	elif(is_circle(line,0.8)):
		return "partial circle"
	elif(is_complete(line)):
		return "complete"
	return "default"
		
func draw_template(template):
	var temp : Array[Vector2]= []
	temp.resize(template.size())
	var k = 0
	for point in template:
		temp[k] = Vector2(point.x,point.y)
		k+=1
	var new_line = Line2D.new()
	new_line.points = temp
	$lines.add_child(new_line)
	$lines.get_child(i).position = Vector2(400,400)
	i+=1

func organize(lines):
	var dis = lines_size(lines)/2
	print(dis)
	var array_points = []
	var points : Array[Point] = []
	while(not lines.is_empty()):
		var main_line = lines.pop_front()
		for point in main_line.points:
					points.append(Point.new(point.x,point.y,0))
		var remaining_lines =[]
		for k in range(0,lines.size()):
			if(mid_point(main_line).distance_to(mid_point(lines[k]))<dis):
				for point in lines[k].points:
					points.append(Point.new(point.x,point.y,k+1))
			else:
				remaining_lines.append(lines[k])
		array_points.append(points)
		points = []
		lines =remaining_lines
	return array_points

func _on_submit_pressed() -> void:
	var templates = Symbols.get_templates()
	var array_points = organize($lines.get_children().filter(func(line): return not line.is_queued_for_deletion()))
	for pointss in array_points:
		var result = Recognizer.p_recognizer(pointss,templates)
		if(result["prob"]!=0):
			print(result["name"])
			print(result["prob"])
			draw_template(result["template"])
		else:
			print("nothing matched")


func _on_clear_pressed() -> void:
	for line in $lines.get_children():
		line.queue_free()
	i = 0
