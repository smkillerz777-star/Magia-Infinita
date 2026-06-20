extends Control


func _on_button_pressed() -> void:
	get_node("/root/main_game").add_child(load("res://information.tscn").instantiate())


func _on_cancel_pressed() -> void:
	queue_free()
