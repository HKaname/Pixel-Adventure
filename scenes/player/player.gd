extends CharacterBody2D
class_name Player

# プレイヤーの状態を定義
enum PLAYER_STATE {
	IDLE,
	RUN,
	JUMP,
	DOUBLE_JUMP,
	WALL_JUMP,
	FALL,
	HIT,
}

var GOAL_ANIM: PackedScene = preload("res://scenes/goalanim/goal_anim.tscn")
var SPAWN_ANIM: PackedScene = preload("res://scenes/spown/spown.tscn")
var JUMP_EFFECT: PackedScene = preload("res://scenes/jump_effect/jump_effect.tscn")
# 重力の設定
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")

# アニメーションスプライトの参照
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_box: Area2D = $HitBox
@onready var jump_buffer: Timer = $Timer/JumpBuffer
@onready var coyote_timer: Timer = $Timer/CoyoteTimer

# 移動関連の設定
@export_group("move")
@export var move_speed: float = 200.0
var can_move: bool = true

# ジャンプ関連の設定
@export_group("jump")
@export var jump_force: float = 300.0  # ジャンプ力
@export var wall_jump_force: Vector2 = Vector2(200.0, -300.0)
@export var max_y_velocity: float = 400.0  # 最大Y速度
var cnt_jump: int = 0
var can_jump: bool = false  # ジャンプ可能かどうかのフラグ
var can_wall_jump: bool = false #カベジャンプ可能化のフラグ
var is_wall_touch: bool = false

#ヒット関係の設定
@export_group("hit")
@export var hit_velocity: Vector2 = Vector2(0, -150.0)
var is_falling: bool = false

# プレイヤーの移動と状態管理
var direction: Vector2 = Vector2.ZERO
var state: PLAYER_STATE = PLAYER_STATE.IDLE  # 現在の状態

func _ready() -> void:
	spawn_player()

# 物理処理のメインループ
func _physics_process(delta: float) -> void:
	apply_gravity(delta)  # 重力の適用
	fallen_off()	
	
	if !can_move:
		return
	
	get_input()  # 入力の取得
	apply_movement(delta)  # 移動の適用
	update_state()  # 状態の更新
	
# プレイヤーが落下した際の処理
func fallen_off():
	if global_position.y < 0:
		return
		
	if global_position.y > 0 and !is_falling:
		is_falling = true
	
	# 一定距離落下した場合にプレイヤーをヒット状態に
	if global_position.y > 500:
		set_state(PLAYER_STATE.IDLE)
		SignalManager.on_player_hit.emit()
		is_falling = false

# 重力を適用
func apply_gravity(delta: float):
	if !is_on_floor():  # 床に触れていない場合
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, max_y_velocity)
		
#カベとの接触を判定
func is_touch_wall() -> bool:
	return is_on_floor() == false and (get_slide_collision_count() > 0 and velocity.x != 0)

# プレイヤーの入力を取得
func get_input():
	# 左右移動の入力を取得
	direction.x = Input.get_axis("left", "right")

	# ジャンプの入力処理
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyote_timer.time_left:
			can_jump = true
			cnt_jump = 1
		elif cnt_jump == 1 and !is_touch_wall():
			can_jump = true
			cnt_jump += 1
		elif is_touch_wall():
			velocity = Vector2(-direction.x * wall_jump_force.x, wall_jump_force.y)
			is_wall_touch = false
			set_state(PLAYER_STATE.WALL_JUMP)
			can_wall_jump = false
			
		if velocity.y > 0 and not is_on_floor():
			jump_buffer.start()
			
# プレイヤーの移動処理
func apply_movement(delta: float):
	if can_jump or jump_buffer.time_left and is_on_floor():
		jump(jump_force)
		
	elif direction.x:
		# プレイヤーの向きを左右反転
		animated_sprite_2d.flip_h = direction.x < 0
		velocity.x = direction.x * move_speed  # 横方向の移動速度
	else:
		velocity.x = 0  # 横方向の速度をリセット
		
	#カベのスライド
	if is_touch_wall() and !is_on_floor() and velocity.y > 0:
		is_wall_touch = true
		velocity.y = min(velocity.y, 50.0)
		can_wall_jump = true
	else:
		is_wall_touch = false
		
	var on_floor = is_on_floor()
	move_and_slide()
	if on_floor and not is_on_floor() and velocity.y >= 0:
		coyote_timer.start()
		
func jump(froce: float):
	velocity.y = -froce
	can_jump = false

# プレイヤーの状態を更新
func update_state():
	if is_on_floor():  # プレイヤーが地面に触れている場合
		cnt_jump = 0
		
		if velocity.x == 0:
			set_state(PLAYER_STATE.IDLE)  # 待機状態
		else:
			set_state(PLAYER_STATE.RUN)  # 走行状態
	else:
		if velocity.y > 0:
			set_state(PLAYER_STATE.FALL)  # 落下状態				
		elif cnt_jump == 1:
			set_state(PLAYER_STATE.JUMP)  # ジャンプ状態
		elif cnt_jump == 2:
			set_state(PLAYER_STATE.DOUBLE_JUMP) #ダブルジャンプ
		elif is_wall_touch:
			set_state(PLAYER_STATE.WALL_JUMP)
			
# プレイヤーの状態を設定
func set_state(new_state: PLAYER_STATE):
	if new_state == state:  # 状態が変更されていない場合
		return

	state = new_state  # 新しい状態に変更

	match state:  # 状態に応じたアニメーションの再生
		PLAYER_STATE.IDLE:
			animated_sprite_2d.play("idle")
		PLAYER_STATE.RUN:
			animated_sprite_2d.play("run")
		PLAYER_STATE.JUMP:
			spawn_jump_effect()
			animated_sprite_2d.play("jump")
		PLAYER_STATE.DOUBLE_JUMP:
			animated_sprite_2d.play("double_jump")
		PLAYER_STATE.FALL:
			animated_sprite_2d.play("fall")
		PLAYER_STATE.HIT:
			animated_sprite_2d.play("hit")
		PLAYER_STATE.WALL_JUMP:
			animated_sprite_2d.play("wall_jump")
			
func add_child_deferred(child_to_add):
	get_tree().root.add_child(child_to_add)

func call_add_child(child_to_add):
	call_deferred("add_child_deferred", child_to_add)
			
func spawn_jump_effect():
	var jump_effect = JUMP_EFFECT.instantiate()
	jump_effect.global_position = global_position + Vector2(0, 9.5)
	jump_effect.flip_h = animated_sprite_2d.flip_h
	call_add_child(jump_effect)

func spawn_player():
	animated_sprite_2d.flip_h = false
	
	var spawn = SPAWN_ANIM.instantiate()
	spawn.global_position = global_position
	call_add_child(spawn)
	
	can_move = false
	await get_tree().create_timer(0.5).timeout
	can_move = true
	
func apply_hit():
	var clear_anim = GOAL_ANIM.instantiate()
	clear_anim.global_position = global_position
	call_add_child(clear_anim)
	
	can_move = false
	velocity = Vector2.ZERO
	set_state(PLAYER_STATE.HIT)
	await  animated_sprite_2d.animation_finished
	set_state(PLAYER_STATE.IDLE)
	can_move = true
	
	SignalManager.on_player_hit.emit()

func _on_hit_box_area_entered(area: Area2D) -> void:
	apply_hit()
