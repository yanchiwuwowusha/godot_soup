extends CharacterBody2D

@export var acceleration: float = 3000.0
@export var max_speed: float = 1000.0
@export var jump_velocity: float = -1000.0
@export var gravity: float = 2000.0
@export var current_stage:int  = 0
@export var hp :float= 100.0
var max_hp:float = 100.0

@export var clarity:float = 100.0
var max_clarity:float = 100.0
@export var oil: float = 100.0
var max_oil: float = 100.0
@export var water: float = 100.0
var max_water: float = 100.0
@export var spiciness: float = 0.0
var max_spiciness: float = 100.0
@export var temperature: float = 0.0
var max_temperature : float = 100.0
@export var salt : float =0.0
var max_salt : float = 100.0
@export var sauce : float =0.0
var max_sauce :float = 100.0
@export var sugar : float = 0.0
var max_sugar : float =0.0
@export var savory : float = 0.0
var max_savory : float = 100.0

@export var soup_type: SoupType
@export var buff_label : Array[BuffType]

@export var coyote_counter: float = 0.0


@onready var hp_label: Label = $CanvasLayer/HPLabel
@onready var clarity_label: Label = $CanvasLayer/ClarityLabel
@onready var water_label: Label = $CanvasLayer/WaterLabel
@onready var oil_label: Label = $CanvasLayer/OilLabel
@onready var Spiciness_label : Label = $CanvasLayer/Spiciness
@onready var Temperature_label : Label = $CanvasLayer/Temperature
@onready var Salt_label : Label = $CanvasLayer/Salt
@onready var Sauce_label : Label = $CanvasLayer/Sauce
@onready var Sugar_label : Label = $CanvasLayer/Sugar
@onready var Savory_label : Label = $CanvasLayer/Savory

func _ready() -> void:
	add_to_group("player")

	
func update_ui():
	hp_label.text = "HP: %d / %d" % [hp, max_hp]
	clarity_label.text = "Clarity: %d / %d" % [clarity, max_clarity]
	water_label.text = "Water: %d / %d" % [water, max_water]
	oil_label.text = "Oil: %d / %d" % [oil, max_oil]    
	Spiciness_label.text = "Spice: %d" % spiciness    
	Temperature_label.text = "Temp: %d" % temperature    
	Salt_label.text = "Salt: %d" % salt    
	Sauce_label.text = "Sauce: %d" % sauce    
	Sugar_label.text = "Sugar: %d" % sugar   
	Savory_label.text = "Savory: %d" % savory
	
	
func _process(_delta):
	clarity_calculation()
	clampVariable()
	update_ui()
	
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
		acceleration = 500.0
		max_speed = 500.0
		jump_velocity = -400.0
		print("形态0")

func change_hp(a:float)->void:
#更改血量
	hp+=a
	hp=min(max_clarity,hp)
	hp=max(0,hp)
	hp_label.text = "HP: %d / %d" % [hp, max_hp]
	
func clampVariable()->void:
	water = clamp(water,0, max_water)
	oil = clamp(oil, 0 , max_oil)
	spiciness = clamp(spiciness, 0, max_spiciness)
	temperature = clamp(temperature, 0, max_temperature)
	salt = clamp(salt, 0, max_salt)
	sauce = clamp(sauce, 0, max_sauce)
	sugar = clamp(sugar, 0, max_sugar)
	savory = clamp(savory, 0, max_savory)

#func change_clarity(a:float)->void:
#更改纯净度
	#clarity+=a
	#clarity=min(max_clarity,clarity)
	#clarity=max(0,clarity)
	#clarity_label.text = "Clarity: %d / %d" % [clarity, max_clarity]
	
func clarity_calculation()->void:
	var water_difference = abs(water - soup_type.water)
	var oil_difference = abs(oil - soup_type.oil)
	var spice_difference = abs(spiciness - soup_type.spiciness)
	var temperature_difference = abs(temperature - soup_type.temperature)
	var salt_difference = abs(salt - soup_type.salt)
	var sauce_difference = abs(sauce - soup_type.sauce)
	var sugar_difference = abs(sugar - soup_type.sugar)
	var savory_difference = abs(savory - soup_type.savory)
	
	var square_sum = pow(water_difference,2) + pow(oil_difference, 2) + pow (spice_difference, 2) + pow(temperature_difference, 2) + pow(salt_difference, 2) + pow(sauce_difference,2) + pow(sugar_difference ,2) + pow(savory_difference, 2)
	clarity = square_sum / 8
	
func pickup_props(prop: PropType)->void:
	water += prop.water
	oil += prop.oil
	spiciness += prop.spiciness
	temperature += prop.temperature
	salt += prop.salt
	sauce += prop.sauce
	sugar += prop.sugar
	savory += prop.savory
	
	if prop.buffs:    # 假设 PropType 里有 buffs: Array[BuffType]
		for buff in prop.buffs:
			if buff.buff_logic:
				var buff_instance = buff.buff_logic.new()
				if buff_instance is Node:
					add_child(buff_instance)
			
	
	
	
	
