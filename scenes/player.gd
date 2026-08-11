extends CharacterBody2D
#速度与加速度
@export var acceleration: float = 3000.0
@export var max_speed: float = 1000.0
@export var jump_velocity: float = -1000.0
@export var gravity: float = 2000.0
#状态   0：瓦罐   1：玻璃罐   2：石锅     3：自热饭盒
@export var current_stage:int  = 0
@export var stage_datas: Array[StageData] = []
#生命与纯净度
@export var hp :float= 100.0
@export var max_hp:float = 100.0
@export var clarity:float = 100.0
@export var max_clarity:float = 100.0
#击退状态
var is_knocked_back: bool = false
var knockback_timer: float = 0.0
const KNOCKBACK_DURATION: float = 0.3


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

	move_and_slide()

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

	if anim and data.anim_name:
		anim.play(data.anim_name)
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
	print("切换到形态：", data.stage_name)

func change_hp(a:float)->void:
#更改血量
	if a < -30:
		hit_sound.play()
	hp+=a
	hp=min(max_clarity,hp)
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
