extends CharacterBody2D
#速度与加速度
@export var acceleration: float = 3000.0
@export var max_speed: float = 1000.0
@export var jump_velocity: float = -1000.0
@export var gravity: float = 2000.0
#状态   0：瓦罐   1：玻璃罐   2：石锅     3：自热饭盒
@export var current_stage:int  = 0
#生命与纯净度
@export var hp :float= 100.0
@export var max_hp:float = 100.0
@export var clarity:float = 100.0
@export var max_clarity:float = 100.0


@onready var hp_label: Label = $CanvasLayer/HPLabel
@onready var clarity_label: Label = $CanvasLayer/ClarityLabel
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	add_to_group("player")
	hp_label.text = "HP: %d / %d" % [hp, max_hp]
	clarity_label.text = "Clarity: %d / %d" % [clarity, max_clarity]
func _physics_process(delta: float) -> void:
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
	if a == 0:
		acceleration = 3000.0
		max_speed = 1000.0
		jump_velocity = -1000.0
		max_hp=100
		max_clarity=100
		anim.play("瓦罐")
		print("瓦罐")
	if a==1:
		acceleration = 6000.0
		max_speed = 2000.0
		jump_velocity = -2000.0
		max_hp=50
		max_clarity=50
		anim.play("玻璃罐")
		print("玻璃罐")
	if a==2:
		acceleration = 1500.0
		max_speed = 500.0
		jump_velocity = 0
		max_hp=200
		max_clarity=200
		anim.play("石锅")
		print("石锅")
	if a==3:
		acceleration = 3000.0
		max_speed = 1000.0
		jump_velocity = -1000.0
		max_hp=100
		max_clarity=100
		anim.play("自热饭盒")
		print("自热饭盒")

func change_hp(a:float)->void:
#更改血量
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
