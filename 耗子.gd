extends CharacterBody2D

@export var speed: float = 1200.0
@export var damage: float = 40.0
@export var knockback_strength: float = 4000.0
@export var chase_duration: float = 20.0        # 追击最大时间（秒）

var triggered: bool = false
var chase_timer: float = 0.0

@onready var detection_area: Area2D = $DetectionArea
@onready var chase_music: AudioStreamPlayer = $ChaseMusic

func _ready() -> void:
	detection_area.body_entered.connect(_on_detection_body_entered)

func _on_detection_body_entered(body: Node2D) -> void:
	if triggered:
		return
	if body.is_in_group("player"):
		triggered = true
		detection_area.monitoring = false
		# 开始播放追击音乐
		chase_music.play()

func _physics_process(delta: float) -> void:
	if not triggered:
		return

	# 追击计时，超时后自毁
	chase_timer += delta
	if chase_timer >= chase_duration:
		queue_free()
		return

	# 向左冲刺
	velocity.x = -speed
	velocity.y = 0
	move_and_slide()

	# 检测碰撞到玩家
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
