extends Area2D

@onready var anim2D: AnimatedSprite2D = $AnimatedSprite2D

const FRUIT: Array = ["apple", "banana", "cherry", "kiwi", "watermelon", "orange", "pine", "strawberry"]
const GET_ANIM: PackedScene = preload("res://scenes/get/get_anim.tscn")

func _ready() -> void:
	anim2D.play(FRUIT.pick_random())

func add_child_deferred(child_to_add):
	get_tree().root.add_child(child_to_add)
	
func call_add_child(child_to_add):
	call_deferred("add_child_deferred", child_to_add)
	
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		SignalManager.on_pickup_item.emit()
		
		var get_anim = GET_ANIM.instantiate()
		get_anim.global_position = global_position
		call_add_child(get_anim)
		queue_free()
