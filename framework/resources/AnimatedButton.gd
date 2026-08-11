extends Button

class_name AnimatedButton

const REST_SCALE := Vector2.ONE
const HOVER_SCALE := Vector2(1.1,1.1)
const SQUASH_SCALE := Vector2(1.15, 0.9)

const HOVER_TIME := 0.2
const SQUASH_TIME := 0.1
var _tween: Tween = null

func _ready()-> void:
	offset_transform_enabled = true
	mouse_entered.connect(_on_anim_button_mouse_entered)
	mouse_exited.connect(_on_anim_button_mouse_exited)
	mouse_exited.connect(_on_anim_button_button_down)
	
func _restart_tween()-> Tween:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	return _tween
	
func _on_anim_button_mouse_entered()-> void:
	_restart_tween().tween_property(self, ^"offset_transform_scale", HOVER_SCALE, HOVER_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
func _on_anim_button_mouse_exited()-> void:
	_restart_tween().tween_property(self, ^"offset_transform_scale", REST_SCALE, HOVER_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
func _on_anim_button_button_down()-> void:
	pass
	var tween: Tween = _restart_tween()
	tween.tween_property(self, ^"offset_transform_scale", SQUASH_SCALE, SQUASH_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, ^"offset_transform_scale", HOVER_SCALE, HOVER_TIME).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
