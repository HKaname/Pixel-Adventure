extends Node2D

@onready var spiked_ballhead: RigidBody2D = $SpikedBallHead

@export var oscillation_force: float = 600.0

func _ready() -> void:
	spiked_ballhead.apply_central_impulse(Vector2(oscillation_force, 0))
