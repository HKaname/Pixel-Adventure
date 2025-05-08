extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if Input.is_action_just_pressed("instage"):
		GameManager.load_level_scene()
