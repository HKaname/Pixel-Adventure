extends Node2D

func _ready() -> void:
	get_tree().paused = false  # ゲームを開始する際には一時停止を解除
