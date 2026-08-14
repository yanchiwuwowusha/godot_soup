extends Control

@onready var button: Button = $Button
@onready var button_2: Button = $Button2
@onready var button_3: Button = $Button3


func _ready() -> void:
	button.pressed.connect(_on_stage_selected.bind(0))
	button_2.pressed.connect(_on_stage_selected.bind(1))
	button_3.pressed.connect(_on_stage_selected.bind(2))

func _on_stage_selected(stage: int) -> void:
	Data.selected_soup_incredients = stage
	get_tree().change_scene_to_file("res://scenes/main.tscn")
