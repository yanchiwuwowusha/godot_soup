extends Area2D

var triggered := false 

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
#一次性+扣纯净度+跳跃力上升
	if not body.is_in_group("player") or triggered:
		return
	triggered = true
	monitoring = false
	hide()  

	if body.has_method("change_clarity"):
		body.change_clarity(-15)
	body.jump_velocity-=500
	queue_free()
