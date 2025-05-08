extends Node2D

func _ready() -> void:
	get_tree().paused = false  # メニュー画面が表示されるとき、ゲームの一時停止を解除する
