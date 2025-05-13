extends Node2D

@export var attack_distance: float = 100.0
@export var attack_speed: float = 300.0

@onready var area: Area2D = $Area2D
@onready var anim_sprite_2d: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var player_detector: RayCast2D = $Area2D/PlayerDetector
@onready var attack_timar: Timer = $Attack

var can_attack: bool = true
var start_position: Vector2

func _ready() -> void:
	start_position = area.global_position
	player_detector.target_position.y = attack_distance
	
func _physics_process(delta: float) -> void:
	if player_detector.is_colliding():
		attack()
		
func attack():
	if !can_attack:
		return
		
	can_attack = false
	anim_sprite_2d.play("blink")
	attack_timar.start()
	
	move_position(start_position + Vector2(0,attack_distance))
	
func move_position(target_position: Vector2):
	var distance = area.global_position.distance_to(target_position)
	var move_time = distance / attack_speed
	
	var tween = get_tree().create_tween()
	tween.tween_property(area, "global_position", target_position, move_time).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(0.1)
	tween.tween_property(area, "global_position", start_position, move_time).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	
func _on_attack_timeout() -> void:
	can_attack = true
