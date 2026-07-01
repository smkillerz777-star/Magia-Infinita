extends Node3D
var i = 1
func _ready() -> void:
	var mat = $floor/mesh.get_active_material(0) as StandardMaterial3D
	if(mat):
		mat.albedo_texture = $SubViewport.get_texture()
		pass
func _process(delta: float) -> void:
	#$SubViewport/ColorRect.color.r = (1+int($SubViewport/ColorRect.color.r))%255
	#var mat = $floor/mesh.get_active_material(0) as StandardMaterial3D
	$SubViewport.add_child(Line2D.new())
	var line = $SubViewport.get_child(i) as Line2D
	line.add_point(Vector2(720-i,720))
	line.add_point(Vector2(719-i,720))
	i+=1
