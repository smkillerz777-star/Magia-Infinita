extends Node
func translate_to_origin(points : customLine2D):
	var temp = []
	temp.resize(points.size())
	var k = 0
	var centroid = Vector2(0,0)
	for point in points:
		centroid.x += point.x
		centroid.y += point.y
		temp[k] = Point.new(point.x,point.y,point.stroke_id)
		k+=1
	centroid /= points.size()
	for point in temp:
		point.x -= centroid.x
		point.y -= centroid.y
	return temp

func scale(points):
	var temp = []
	temp.resize(points.size())
	var max_x = -INF
	var max_y = -INF
	var min_x = INF
	var min_y = INF
	var k = 0
	for point in points:
		max_x = max(max_x,point.x)
		max_y = max(max_y,point.y)
		min_x = min(min_x,point.x)
		min_y = min(min_y,point.y)
		temp[k] = Point.new(point.x,point.y,point.stroke_id)
		k+=1
	var scale_factor = max(max_x-min_x,max_y-min_y)
	var corner = Vector2(min_x,min_y)
	k=0
	for point in temp:
		point.x = (point.x-corner.x)/scale_factor
		point.y = (point.y-corner.y)/scale_factor
	return temp

func path_length(points):
	var d = 0.0
	for i in range(1,points.size()):
		if(points[i-1].stroke_id==points[i].stroke_id):
			d += points[i-1].distance_to(points[i])
	return d

func resample(points,n):
	var interval = path_length(points)/(n-1)
	var dis = 0.0
	var temp = []
	var k = 0
	temp.resize(points.size())
	for point in points:
		temp[k] = point
		k+=1
	var new_points : Array[Point] = []
	new_points.resize(n)
	k = 0
	var i = 1
	while i < temp.size():
		if(temp[i-1].stroke_id==temp[i]):
			var d = temp[i-1].distance_to(temp[i])
			if((dis+d)>interval):
				var qx = temp[i-1].x + ((interval-dis)/d)*(temp[i].x-temp[i-1].x)
				var qy = temp[i-1].y + ((interval-dis)/d)*(temp[i].y-temp[i-1].y)
				var q = Point.new(qx,qy,0)
				new_points[k] = q
				temp.insert(i, q)
				k+=1
				dis = dis + d - interval
			else:
				dis += d
				i+=1
		else:
			i+=1
	return new_points

func normalize(points,n):
	var resampled_points = resample(points, n)
	resampled_points = scale(resampled_points)
	resampled_points = translate_to_origin(resampled_points)
	return resampled_points

func cloud_distance(points,template,n,start):
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

func greedy_cloud_match(points,template,n):
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

func p_recognizer(points,templates):
	var n = 32
	var normalized_points = normalize(points,n)
	var score = INF
	var result = 0
	for template in templates:
		var normalized_template = normalize(template,n)
		var d = greedy_cloud_match(normalized_points,normalized_template,n)
		if(score>d):
			score = d
			result = template
	return {"template": result, "score": score}