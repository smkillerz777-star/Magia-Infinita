extends Node
class_name Recognizer
static func translate_to_origin(points : Array[Point]):
	var temp : Array[Point] = []
	temp.resize(points.size())
	var centroid : Vector2 = Vector2(0,0)
	for point in points:
		centroid.x += point.x
		centroid.y += point.y
	centroid /= points.size()
	var i = 0
	for point in points:
		temp[i] = Point.new(point.x - centroid.x,point.y - centroid.y,point.stroke_id)
		i+=1
	return temp

static func scale(points : Array[Point],multiplier=1):
	var temp : Array[Point] = []
	temp.resize(points.size())
	var max_x : float = -INF
	var max_y : float = -INF
	var min_x : float= INF
	var min_y : float= INF
	for point in points:
		max_x = max(max_x,point.x)
		max_y = max(max_y,point.y)
		min_x = min(min_x,point.x)
		min_y = min(min_y,point.y)
	var scale_factor : float= max(max_x-min_x,max_y-min_y)
	var i = 0
	for point in points:
		temp[i] = Point.new((point.x-min_x)/scale_factor*multiplier, (point.y-min_y)/scale_factor*multiplier,point.stroke_id)
		i+=1
	return temp

static func path_length(points : Array[Point]):
	var d = 0.0
	for i in range(1,points.size()):
		if(points[i-1].stroke_id==points[i].stroke_id):
			d += points[i-1].distance_to(points[i])
	return d

static func resample(points : Array[Point],n):
	var temp : Array[Point] = points.duplicate()
	if(points.is_empty()):                                   
		temp.resize(n)
		for i in range(n):
			temp[i] = Point.new(INF,INF,0)
		return temp
	if(points.size()==1):
		temp.resize(n)
		for i in range(n):
			temp[i] = Point.new(points[0].x,points[0].y,points[0].stroke_id)
		return temp
	var interval = path_length(points)/(n-1)
	var dis = 0.0
	var new_points : Array[Point] = [Point.new(temp[0].x,temp[0].y,temp[0].stroke_id)]
	var i = 1
	while i < temp.size():
		if(temp[i-1].stroke_id==temp[i].stroke_id):
			var d = temp[i-1].distance_to(temp[i])
			if(d==0.0):
				pass
			elif((dis+d)>=interval):
				var t = (interval-dis)/d
				var q = Point.new(lerp(temp[i-1].x, temp[i].x, t),lerp(temp[i-1].y, temp[i].y, t),temp[i].stroke_id)
				new_points.append(q)
				temp.insert(i, q)
				dis = 0.0
			else:
				dis += d
		i+=1
	new_points.resize(n)
	new_points[n-1] = Point.new(points[points.size()-1].x,points[points.size()-1].y,points[points.size()-1].stroke_id)
	return new_points

static func normalize(points : Array[Point],n):
	var resampled_points : Array[Point] = resample(points, n)
	resampled_points = scale(resampled_points)
	resampled_points = translate_to_origin(resampled_points)
	return resampled_points

static func cloud_distance(points : Array[Point],template : Array[Point],n,start):
	var matched : Array[bool] = []
	matched.resize(n)
	var sum = 0.0
	var i = start
	var index = 0
	while(true):
		var minimum = INF
		for j in range(points.size()):
			if(not matched[j]):
				var d = points[i].distance_to(template[j])
				if(d<minimum):
					minimum = d
					index = j
		matched[index] = true
		var weight = 1-((i-start+n)%n)/n
		sum = sum + weight*minimum
		i=(i+1)%n
		if(i==start):
			break
	return sum

static func greedy_cloud_match(points : Array[Point],template : Array[Point],n):
	var epsilon = 0.5
	var step = max(1,int(pow(n,1-epsilon)))
	var minimum = INF
	var i = 0
	while(i<n):
		var d1 = cloud_distance(points,template,n,i)
		var d2 = cloud_distance(template,points,n,i)
		minimum = min(d1,d2,minimum)
		i += step
	return minimum

static func p_recognizer(points : Array[Point],templates):
	var n = 64
	var normalized_points = normalize(points,n)
	var score = INF
	var result = []
	for template in templates:
		var normalized_template = normalize(template,n)
		var d = greedy_cloud_match(normalized_points,normalized_template,n)
		if(score>d):
			score = d
			result = template
	if(result.is_empty()):
		return {"prob" : 0}
	var about = name_template(result)
	return  {"name": about,"template": result,"prob" : max(0.0,1.0-score/(0.2*n))}

static func name_template(temp):
	var con = contains(Symbols.get_templates(),temp)
	if(con!=-1):
		if(con<8):
			return "direction_sign" + str(con)
		elif(con<16):
			return "column_sign" + str(con-8)
		elif(con<24):
			return "levitation_sign" + str(con-16)
		elif(con<32):
			return "pull" + str(con-24)
		elif(con<40):
			return "crush" + str(con-32)
		elif(con<48):
			return "region" + str(con-40)
		elif(con<56):
			return "gather" + str(con-48)
		elif(con<60):
			return "fire" + str(con-56)
		elif(con<68):
			return "earth" + str(con-60)
		elif(con<70):
			return "light" + str(con-68)
		elif(con<74):
			return "water" + str(con-70)
		elif(con<78):
			return "wind" + str(con-74)
		elif(con==Symbols.get_templates().size()-1):
			return "circle"
		else:
			return "currently not listed"
	else:
		return "not found"

static func contains(templates,temp):
	for i in range(templates.size()):
		if(is_identical(templates[i],temp)):
			return i
	return -1
static func is_identical(t1,t2):
	if(t1.size()!=t2.size()):
		return false
	for i in range(t1.size()):
		if((t1[i].x!=t2[i].x) or (t1[i].y!=t2[i].y)):
			return false
	return true
