extends Control

@export var position_count: int = 0
@export var box_color: Color = Color.BLACK

@onready var position_label: Node = $PositionLabel
@onready var color_rect: Node = $ColorRect

func _ready() -> void:
	color_rect.color = box_color
	position_label.text = str(position_count)
