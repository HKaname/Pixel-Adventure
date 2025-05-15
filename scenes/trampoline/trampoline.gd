extends Area2D

@onready var anim_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var jump_force: float = 600.0

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		anim_2d.play("jump")
		body.jump(jump_force)
