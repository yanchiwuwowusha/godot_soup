extends CharacterBody2D
#速度与加速度
@export var acceleration: float = 3000.0
@export var max_speed: float = 1000.0
@export var jump_velocity: float = -1000.0
@export var gravity: float = 2000.0
#状态   0：瓦罐   1：玻璃罐   2：石锅     3：自热饭盒
@export var current_stage:int  = 0
@export var stage_datas: Array[StageData] = []
#汤底   
var soup_base : int = 0
#汤料
var soup_incredients:int =0
#生命与纯净度
@export var hp :float= 100.0
@export var max_hp:float = 100.0
@export var clarity:float = 100.0
@export var max_clarity:float = 100.0
#击退状态
var is_knocked_back: bool = false
var knockback_timer: float = 0.0
const KNOCKBACK_DURATION: float = 0.3
#子弹
@export var bullet_scene: PackedScene         
@export var fire_cooldown: float = 0.2         # 开火冷却时间
var fire_timer: float = 0.0                    # 冷却计时器

@onready var hit_sound: AudioStreamPlayer = $HitSound
@onready var hp_label: Label = $CanvasLayer/HPLabel
@onready var clarity_label: Label = $CanvasLayer/ClarityLabel
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
#罐子形状
@onready var 自热饭盒shape: CollisionPolygon2D = $自热饭盒shape
@onready var 瓦罐shape: CollisionPolygon2D = $瓦罐shape
@onready var 石锅shape: CollisionPolygon2D = $石锅shape
@onready var 玻璃罐shape: CollisionPolygon2D = $玻璃罐shape

func _ready() -> void:
	add_to_group("player")
	hp_label.text = "HP: %d / %d" % [hp, max_hp]
	clarity_label.text = "Clarity: %d / %d" % [clarity, max_clarity]
	change_current_stage(Data.selected_stage)
	change_soup_base(Data.selected_soup_base)
	change_soup_incredients(Data.selected_soup_incredients)
	update_display()
func _physics_process(delta: float) -> void:
	if is_knocked_back:
		knockback_timer -= delta
		velocity.y += gravity * delta   # 依然受重力影响
		move_and_slide()
		if knockback_timer <= 0.0 or is_on_floor():
			is_knocked_back = false
		return   # 跳过后续正常移动代码
	
	
#重力
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0
#左右移动与跳跃
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
#开火
	if fire_timer > 0.0:
		fire_timer -= delta

  # 按下开火键
	if Input.is_action_just_pressed("fire") and fire_timer <= 0.0:
		_fire()
		fire_timer = fire_cooldown

	move_and_slide()
	update_animation()

func change_current_stage(a: int) -> void:
#切换各种形态
	current_stage = a
	if a < 0 or a >= stage_datas.size():
		print("错误：形态索引 %d 超出资源数组范围" % a)
		return


	var data: StageData = stage_datas[a]
	acceleration = data.acceleration
	max_speed = data.max_speed
	jump_velocity = data.jump_velocity
	max_hp = data.max_hp
	max_clarity = data.max_clarity

	# 限制当前 hp/clarity 不超过最大值
	hp = min(hp, max_hp)
	clarity = min(clarity, max_clarity)

	for shape in get_children():
		if shape is CollisionPolygon2D:
			shape.disabled = true

	# 启用指定的形状
	if not data.shape_name.is_empty():
		var target_shape = get_node_or_null(data.shape_name)
		if target_shape is CollisionPolygon2D:
			target_shape.disabled = false
		else:
			print("警告：未找到碰撞形状节点：", data.shape_name)
	update_display()
	update_animation()
	print("切换到形态：", data.stage_name)

func change_soup_base(a:int)->void:
	pass
func change_soup_incredients(a:int)->void:
	pass

func change_hp(a:float)->void:
#更改血量
	if a < -30:
		hit_sound.play()
	hp+=a
	hp=min(max_hp,hp)
	hp=max(0,hp)
	hp_label.text = "HP: %d / %d" % [hp, max_hp]

func change_clarity(a:float)->void:
#更改纯净度
	clarity+=a
	clarity=min(max_clarity,clarity)
	clarity=max(0,clarity)
	clarity_label.text = "Clarity: %d / %d" % [clarity, max_clarity]

func update_display()->void:
#刷新
	hp_label.text = "HP: %d / %d" % [hp, max_hp]
	clarity_label.text = "Clarity: %d / %d" % [clarity, max_clarity]

func apply_knockback(direction: Vector2, strength: float) -> void:
#被击退
	velocity = direction * strength
	is_knocked_back = true
	knockback_timer = KNOCKBACK_DURATION

func update_animation() -> void:
	if anim == null:
		return

	if current_stage < 0 or current_stage >= stage_datas.size():
		return

	var data: StageData = stage_datas[current_stage]
	var base_name: String = data.anim_name

	if base_name.is_empty():
		return

	var target_anim: String = base_name

	# 跳跃优先
	if not is_on_floor():
		target_anim = base_name + "跳"
	# 地面移动
	elif not is_zero_approx(velocity.x):
		target_anim = base_name + "跑"
		# 向左跑则水平翻转，向右跑则不变
		anim.flip_h = velocity.x < 0.0
	# 静止时保持原来的翻转状态，不额外修改

	# 避免重复播放同一动画
	if anim.animation != target_anim:
		anim.play(target_anim)

func _fire() -> void:
	if bullet_scene == null:
		print("错误：未设置子弹场景")
		return

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)

	# 设置子弹出生位置在主角前方一点
	var spawn_offset = Vector2(50, -20)  # 可调整偏移量
	var facing = 1.0
	if anim.flip_h:   # 动画水平翻转时面向左
		facing = -1.0

	bullet.global_position = global_position + Vector2(spawn_offset.x * facing, spawn_offset.y)

	# 设置子弹速度方向
	if bullet.has_method("set_velocity"):
		bullet.set_velocity(Vector2(bullet.speed * facing, 0))
	else:
		# 如果子弹脚本中没有 set_velocity，可以直接修改 velocity
		bullet.velocity = Vector2(bullet.speed * facing, 0)
