extends Area2D

var triggered := false 

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
#一次性+扣hp+扣纯净度
	if not body.is_in_group("player") or triggered:
		return
	triggered = true
	monitoring = false
	hide()  

	if body.has_method("change_clarity"):
		body.change_clarity(-10)
	_start_damage(body)

func _start_damage(body: Node2D) -> void:
# 4 秒内每秒扣血 2.5
	for i in range(4):
		if not is_instance_valid(body):
			break
		if body.has_method("change_hp"):
			body.change_hp(-2.5)
		await get_tree().create_timer(1.0).timeout
	queue_free()
