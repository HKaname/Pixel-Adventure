extends Control

@onready var level: Label = %Level
@onready var timer: Label = %Timer
@onready var item: Label = %Item
@onready var background: ColorRect = %Background
@onready var game_clear: CenterContainer = %GameClear
@onready var score: Label = %Score
@onready var button = [%Main, %Quit]

var button_index = 0
var total_level: int = GameManager.get_total_level()

func _ready() -> void:
	# 常時プロセスを有効化
	set_process_mode(Node2D.PROCESS_MODE_ALWAYS)
	
	set_level_lavel()
	set_item_label()
	hide_hud()  # HUDを初期状態で非表示にする
	
	SignalManager.on_pickup_item.connect(on_pickup_item)
	SignalManager.on_game_complete.connect(on_game_complete)  # ゲーム完了時のシグナルに接続

func _process(delta: float) -> void:
	var total_time = ScoreManager.total_time
	update_timer(total_time)
	
	# ゴール後、入力待ち状態になる
	if background.visible:
		select_input()

func update_timer(time: float) -> void:
	var minutes = int(time / 60)
	var seconds = int(time) % 60
	var millisecond = int((time - int(time)) * 100)
	
	var time_text = "%02d:%02d:%02d" % [minutes, seconds, millisecond]
	timer.text = time_text

# HUDを非表示
func hide_hud():
	background.visible = false
	game_clear.visible = false

# HUDを表示
func show_hud():
	get_tree().paused = true  # ゲームを一時停止
	button[0].grab_focus()
	background.visible = true
	
func set_level_lavel():
	var current_level = GameManager.get_current_level()
	if total_level == current_level:
		level.text = "FINAL STAGE"
	else:
		level.text = "STAGE" + str(current_level)
		
func set_item_label():
	item.text = str(ScoreManager.get_total_item())
	
func on_pickup_item():
	set_item_label()

# ゴール時に呼び出される関数
func on_game_complete():
	game_clear.visible = true
	score.text = "Score: " + str(ScoreManager.calculate_score())
	show_hud()
	
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


func _on_main_pressed() -> void:
	GameManager.load_main_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
