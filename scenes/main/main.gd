extends Node2D

@onready var button = [%Start, %Quit]

var button_index = 0

func _ready() -> void:
	 # メニュー画面が表示されるとき、ゲームの一時停止を解除する
	get_tree().paused = false
	ScoreManager.reset()
	button[0].grab_focus()
	
func _process(delta: float) -> void:
	select_input()
	
func select_input():
	if Input.is_action_just_pressed("ui_up"):
		move_focus(-1)
	elif Input.is_action_just_pressed("ui_down"):
		move_focus(1)
	elif Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_select"):
		button[button_index].emit_signal("pressed")
		
func move_focus(direction: int) -> void:
	button[button_index].release_focus()
	
	button_index = (button_index + direction + button.size()) % button.size()
	button[button_index].grab_focus()

func _on_start_pressed() -> void:
	GameManager.load_next_level()

func _on_quit_pressed() -> void:
	get_tree().quit()
