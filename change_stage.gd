extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("change_current_stage") and body.get("current_stage") != null:
		var next_stage = (body.current_stage + 1) % 4
		body.change_current_stage(next_stage)
