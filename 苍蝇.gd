extends CharacterBody2D

@export var speed: float = 600.0
@export var damage: float = 40.0
@export var knockback_strength: float = 1000.0
@export var chase_duration: float = 20.0

const TAKEOFF_DURATION: float = 0.5
const TAKEOFF_SPEED: float = 100.0

enum State { IDLE, TAKEOFF, CHASING }

var state: State = State.IDLE
var takeoff_timer: float = 0.0
var chase_timer: float = 0.0
var player: Node2D = null

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

@onready var detection_area: Area2D = $DetectionArea
@onready var chase_music: AudioStreamPlayer = $ChaseMusic
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	anim.play("待机")
	detection_area.body_entered.connect(_on_detection_body_entered)

func _on_detection_body_entered(body: Node2D) -> void:
	if state != State.IDLE:
		return
	if body.is_in_group("player"):
		player = body
		detection_area.monitoring = false
		state = State.TAKEOFF
		takeoff_timer = 0.0
		anim.play("起飞")
func _physics_process(delta: float) -> void:
	# 击退优先处理（即使在死亡状态，击退也生效）
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

	if state == State.IDLE:
		return

	if not is_instance_valid(player):
		queue_free()
		return

	match state:
		State.TAKEOFF:
			takeoff_timer += delta
			velocity = Vector2(0, -TAKEOFF_SPEED)
			move_and_slide()
			if takeoff_timer >= TAKEOFF_DURATION:
				state = State.CHASING
				anim.play("追击")
				chase_music.play()
			return

		State.CHASING:
			chase_timer += delta
			if chase_timer >= chase_duration:
				queue_free()
				return

			if player.global_position.x < global_position.x:
				anim.flip_h = true
			else:
				anim.flip_h = false

			var direction := global_position.direction_to(player.global_position)
			velocity = direction * speed
			move_and_slide()

			for i in range(get_slide_collision_count()):
				var collision = get_slide_collision(i)
				var collider = collision.get_collider()
				if collider.is_in_group("player"):
					collider.change_hp(-damage)
					var knockback_dir = (player.global_position - global_position).normalized()
					knockback_dir += Vector2(0, -0.5)
					knockback_dir = knockback_dir.normalized()
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
	state = State.IDLE
	detection_area.monitoring = false
	collision_layer = 0
	collision_mask = 0

	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("战败"):
		anim.play("战败")
