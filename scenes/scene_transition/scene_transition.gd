extends CanvasLayer

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func change_scene():
	anim_player.play("dissolve")
	await anim_player.animation_finished
	GameManager.load_next_level()
	anim_player.play_backwards("dissolve")
