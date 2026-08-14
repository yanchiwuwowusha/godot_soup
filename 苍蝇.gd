extends CharacterBody2D

@export var speed: float = 800.0                # 追踪移动速度
@export var damage: float = 40.0
@export var knockback_strength: float = 4000.0
@export var chase_duration: float = 20.0        # 追击最大时间（秒）

var triggered: bool = false
var chase_timer: float = 0.0
var player: Node2D = null                       # 缓存玩家引用

@onready var detection_area: Area2D = $DetectionArea
@onready var chase_music: AudioStreamPlayer = $ChaseMusic
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	anim.play("待机")
	detection_area.body_entered.connect(_on_detection_body_entered)

func _on_detection_body_entered(body: Node2D) -> void:
	if triggered:
		return
	if body.is_in_group("player"):
		triggered = true
		player = body
		detection_area.monitoring = false
		anim.play("追击")
		chase_music.play()

func _physics_process(delta: float) -> void:
	if not triggered:
		return

	if not is_instance_valid(player):
		queue_free()
		return

	chase_timer += delta
	if chase_timer >= chase_duration:
		queue_free()
		return

	# ---- 根据玩家位置翻转动画 ----
	if player.global_position.x < global_position.x:
		# 主角在敌人左侧 -> 敌人面朝左（假设原始动画朝右）
		anim.flip_h = true
	else:
		# 主角在敌人右侧 -> 敌人面朝右
		anim.flip_h = false
	# ---------------------------------

	# 实时追踪
	var direction := global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()

	# 碰撞检测：碰到玩家后造成伤害并击退
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("player"):
			collider.change_hp(-damage)

			# 击退方向：从敌人指向玩家，并稍向上偏移
			var knockback_dir = (player.global_position - global_position).normalized()
			knockback_dir += Vector2(0, -0.5)   # 增加一点向上分量
			knockback_dir = knockback_dir.normalized()

			if collider.has_method("apply_knockback"):
				collider.apply_knockback(knockback_dir, knockback_strength)

			queue_free()
			return
