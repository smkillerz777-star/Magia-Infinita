extends Node
class_name Point
@export var stroke_id  = 0
@export var x = 0
@export var y = 0
func distance_to(point):
    var p1 = Vector2(x,y)
    var p2 = Vector2(point.x,point.y)
    return p1.distance_to(p2)
func _init(p_x,p_y,p_stroke_id):
    x = p_x
    y = p_y
    stroke_id = p_stroke_id