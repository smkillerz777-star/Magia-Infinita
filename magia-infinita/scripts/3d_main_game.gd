extends Node3D
func _ready() -> void:
    var mat = $floor/mesh.get_active_material(0) as StandardMaterial3D
    if(mat):
        mat.albedo_texture = $SubViewport.get_texture()
