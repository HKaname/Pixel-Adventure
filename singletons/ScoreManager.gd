extends Node

const SCORE_FILE: String = "user://PIXSELADVENTRUE_SCORE.dat"

var total_time: float = 0.0
var total_item: int = 0

func _ready() -> void:
	SignalManager.on_pickup_item.connect(on_pickup_item)
	
func reset():
	total_time = 0.0
	total_item = 0
	
func add_time(delta: float):
	total_time += delta
	
func calculate_score():
	var time_penalty = int(total_time)
	var score = total_item * 10 - time_penalty
	
	return score
	
func get_total_item() -> int:
	return total_item
	
func on_pickup_item():
	total_item += 1
