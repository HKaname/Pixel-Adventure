extends AnimatableBody2D

@export var start: Marker2D
@export var end: Marker2D
@export var speed: float = 50.0

var tween: Tween

func _ready() -> void:
	var distance = start.global_position.distance_to(end.global_position)
	var move_time = distance / speed
	
	tween = get_tree().create_tween()
	tween.set_loops(0)
	tween.tween_property(self, "global_position", start.global_position, move_time)
	tween.tween_property(self, "global_position", end.global_position, move_time)
	
func _exit_tree() -> void:
	tween.kill()
