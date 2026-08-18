extends Node

## 每秒升温的数值
@export var heat_rate: float = 10.0

# 缓存玩家引用，避免每帧 get_parent()
var player: CharacterBody2D

func _ready() -> void:
	# 假设这个 Buff 节点被添加为玩家的子节点
	player = get_parent() as CharacterBody2D

func _process(delta: float) -> void:
	if player:
		# 根据时间增加温度
		player.temperature += heat_rate * delta
