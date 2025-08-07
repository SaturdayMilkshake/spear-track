extends Control

@export var icon_texture: Texture = null
@export var item_name: String = ""
@export var current_spot: int = 0

@onready var icon: Node = $Icon
@onready var position_name: Node = $PositionName

var success_probability: int = 100

var current_score: int = 0
var current_lap: int = 1

var processing_active: bool = false

func _ready() -> void:
	icon.texture = icon_texture
	position_name.text = item_name
	processing_active = true
	reroll_success_probability()

func _physics_process(_delta: float) -> void:
	if processing_active:
		if check_score_success():
			current_score += 1
			if current_score >= 2500 * current_lap:
				reroll_success_probability()
				current_lap += 1
			$testvalue.text = str(current_score)
			SignalHandler.emit_signal("update_line_follower", item_name, current_score)
	
func reset_values() -> void:
	current_score = 0

func check_score_success() -> bool:
	var result: int = randi_range(0, 100)
	return result >= success_probability

func reroll_success_probability() -> void:
	success_probability = randi_range(10, 15)
