extends Node
class_name Recognizer
static func translate_to_origin(points : Array[Point]):
	var temp : Array[Point] = points.duplicate()
	var centroid : Vector2 = Vector2(0,0)
	for point in temp:
		centroid.x += point.x
		centroid.y += point.y
	centroid /= points.size()
	for point in temp:
		point.x -= centroid.x
		point.y -= centroid.y
	return temp

static func scale(points : Array[Point]):
	var temp : Array[Point] = points.duplicate()
	print(temp.size(),"hi")
	var max_x : float = -INF
	var max_y : float = -INF
	var min_x : float= INF
	var min_y : float= INF
	for point in temp:
		max_x = max(max_x,point.x)
		max_y = max(max_y,point.y)
		min_x = min(min_x,point.x)
		min_y = min(min_y,point.y)
	var scale_factor : float= max(max_x-min_x,max_y-min_y)
	for point in temp:
		point.x = (point.x-min_x)/scale_factor
		point.y = (point.y-min_y)/scale_factor
	return temp

static func path_length(points : Array[Point]):
	var d = 0.0
	for i in range(1,points.size()):
		if(points[i-1].stroke_id==points[i].stroke_id):
			d += points[i-1].distance_to(points[i])
	return d

static func resample(points : Array[Point],n):
	var interval = path_length(points)/(n-1)
	var dis = 0.0
	var temp : Array[Point] = points.duplicate()
	var new_points : Array[Point] = [temp[0]]
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
	new_points[n-1] = points[points.size()-1]
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
	var n = 32
	var normalized_points = normalize(points,n)
	var score = INF
	var result = 0
	var i = 0
	var angle = 0
	for template in templates:
		var normalized_template = normalize(template,n)
		var d = greedy_cloud_match(normalized_points,normalized_template,n)
		if(score>d):
			score = d
			result = template
			angle = i
		i+=5
	print(result)
	return {"angle": angle,"prob" : max(0.0,1.0-score/(0.2*32))}