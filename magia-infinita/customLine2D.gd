extends Line2D
class_name customLine2D
@export var connected : Array[customLine2D] = []
func to_point(stroke_id):
	var temp : Array[Point] = []
	var i = 0
	temp.resize(points.size())
	for point in points:
		temp[i] = Point.new(point.x,point.y,stroke_id)
		i+=1
	return temp
func from_point(inputted_points : Array[Point]):
	var temp : Array[Vector2] = []
	temp.resize(inputted_points.size())
	var i = 0
	for point in inputted_points:
		temp[i] = Vector2(point.x,point.y)
		i+=1
	points = temp

func min_distance(line):
	var minimum = INF
	for i in range(line.points.size()):
		for j in range(points.size()):
			minimum = min(minimum,line.points[i].distance_to(points[j]))
	return minimum
