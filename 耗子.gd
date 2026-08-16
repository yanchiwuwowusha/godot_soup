extends CharacterBody2D

@export var speed: float = 800.0
@export var damage: float = 40.0
@export var knockback_strength: float = 1000.0
@export var chase_duration: float = 20.0

var triggered: bool = false
var chase_timer: float = 0.0

# hp
@export var hp: float = 100.0
@export var max_hp: float = 100.0

# 击退状态
var is_knocked_back: bool = false
var knockback_timer: float = 0.0
const KNOCKBACK_DURATION: float = 0.3
var knockback_velocity: Vector2 = Vector2.ZERO

# 死亡状态
var is_dying: bool = false
var death_timer: float = 0.0
const DEATH_DURATION: float = 1.0

@onready var animat: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var chase_music: AudioStreamPlayer = $ChaseMusic

func _ready() -> void:
	animat.play("待机")
	detection_area.body_entered.connect(_on_detection_body_entered)

func _on_detection_body_entered(body: Node2D) -> void:
	if triggered:
		return
	if body.is_in_group("player"):
		triggered = true
		detection_area.monitoring = false
		animat.play("追击")
		chase_music.play()

func _physics_process(delta: float) -> void:
	if is_knocked_back:
		knockback_timer -= delta
		velocity = knockback_velocity
		velocity.y += 2000.0 * delta
		move_and_slide()
		if knockback_timer <= 0.0 or is_on_floor():
			is_knocked_back = false

		# 死亡时也需要更新死亡计时
		if is_dying:
			death_timer += delta
			if death_timer >= DEATH_DURATION:
				queue_free()
		return

	# 死亡后无击退，只计时
	if is_dying:
		death_timer += delta
		if death_timer >= DEATH_DURATION:
			queue_free()
		return

	if not triggered:
		return

	chase_timer += delta
	if chase_timer >= chase_duration:
		queue_free()
		return

	velocity.x = -speed
	velocity.y = 0
	move_and_slide()

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("player"):
			collider.change_hp(-damage)
			var knockback_dir = Vector2(-1, -0.5).normalized()
			if collider.has_method("apply_knockback"):
				collider.apply_knockback(knockback_dir, knockback_strength)
			queue_free()
			return

func take_damage(amount: float, knockback_dir: Vector2 = Vector2.ZERO, knockback_force: float = 0.0) -> void:
	if is_dying:
		return
	hp -= amount

	if knockback_force > 0.0 and knockback_dir != Vector2.ZERO:
		knockback_velocity = knockback_dir * knockback_force
		is_knocked_back = true
		knockback_timer = KNOCKBACK_DURATION

	if hp <= 0.0:
		_die()

func _die() -> void:
	if is_dying:
		return
	is_dying = true
	death_timer = 0.0

	# 停止一切活动
	triggered = false
	detection_area.monitoring = false
	collision_layer = 0
	collision_mask = 0

	if animat and animat.sprite_frames and animat.sprite_frames.has_animation("战败"):
		animat.play("战败")
