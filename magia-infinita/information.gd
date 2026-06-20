extends Control



func _on_use_pressed() -> void:
	print("use")

func _on_cancel_pressed() -> void:
	queue_free()
