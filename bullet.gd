extends CharacterBody2D

@export var speed: float = 2400.0
@export var damage: float = 200.0
@export var gravity: float = 2000.0
@export var knockback_strength: float = 2000.0 #击退距离

const MAX_LIFETIME: float = 60.0   # 最长存在时间

var is_dead: bool = false
var lifetime: float = 0.0          # 已存在时间

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	anim.play("飞")
	add_to_group("bullet")

func _physics_process(delta: float) -> void:
	# 累计存在时间
	lifetime += delta

	# 超过最大时间则自然消失（即使正在播放动画）
	if lifetime >= MAX_LIFETIME:
		queue_free()
		return

	# 已碎裂则不再移动和碰撞（但仍然计时）
	if is_dead:
		return

	# 重力影响
	velocity.y += gravity * delta

	var collision = move_and_collide(velocity * delta)
	if collision:
		_handle_collision(collision)

func _handle_collision(collision: KinematicCollision2D) -> void:
	if is_dead:
		return
	is_dead = true

	velocity = Vector2.ZERO
	collision_shape.set_deferred("disabled", true)

	var normal = collision.get_normal()
	var collider = collision.get_collider()

	var anim_name := "上碎"
	var flip_h := false

	if abs(normal.x) > abs(normal.y):
		if normal.x > 0.5:
			anim_name = "左碎"
			flip_h = true
		else:
			anim_name = "右碎"
			flip_h = false
	else:
		if normal.y < -0.5:
			anim_name = "下碎"
		else:
			anim_name = "上碎"

	anim.flip_h = flip_h
	anim.play(anim_name)

	# 对敌人造成伤害并击退
	if collider and collider.has_method("take_damage"):
		# 计算击退方向：从子弹指向敌人，并稍微向上
		var knockback_dir = (collider.global_position - global_position).normalized()
		knockback_dir += Vector2(0, -0.3)
		knockback_dir = knockback_dir.normalized()

		collider.take_damage(damage, knockback_dir, knockback_strength)

	# 下碎特殊处理（不立即销毁）
	if anim_name == "下碎":
		return

	if anim.sprite_frames and anim.sprite_frames.has_animation(anim_name):
		await anim.animation_finished
	queue_free()
