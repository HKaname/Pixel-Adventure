extends Node

# タイトル画面のプリロード
const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
#何ステージあるか
const TOTAL_LEVEL: int = 5
#今どこのステージなのか
@export var current_level: int = 0
#各レベルを格納する変数
var level_scene = {}

#init
func _ready() -> void:
	for ln in range(1,TOTAL_LEVEL + 1):
		level_scene[ln] = load("res://scenes/levels/level_%s.tscn" % ln)
		
#何ステージあるのか取得する関数
func get_total_level():
	return TOTAL_LEVEL

#現在のレベルを取得する関数
func get_current_level():
	return current_level
	
# メインメニューシーンをロードする関数
func load_main_scene():
	current_level = 0
	get_tree().change_scene_to_packed(MAIN_SCENE)

#次のレベルをロードする関数
func load_next_level():
	set_next_level()
	get_tree().change_scene_to_packed(level_scene[current_level])
	
#次のステージをセットする関数
func set_next_level():
	current_level += 1
	#最後のステージをクリアしたら最初のステージへ戻す
	if current_level > TOTAL_LEVEL:
		current_level = 1
