extends Control

@export var icon_texture: Texture = null
@export var item_name: String = ""
@export var inital_score: int = 0

@onready var icon: Node = $Icon
@onready var position_name: Node = $PositionName
@onready var finish_rect: Node = $FinishRect
@onready var fastest_lap_rect: Node = $FastestLapRect
@onready var lap_time_offset: Node = $LapTimeOffset

@onready var animation_player: Node = $AnimationPlayer

var success_probability: int = 100

var current_score: int = 0
var current_lap: int = 1
var max_laps: int = 1

var lap_time: float = 0.0
var total_lap_time: float = 0.0
var final_lap_time: float = 0.0

var processing_active: bool = false
var unsortable: bool = false
var final_lap_time_set: bool = false
var current_fastest_lap: bool = false

func _ready() -> void:
	current_lap = 1
	icon.texture = icon_texture
	position_name.text = item_name
	processing_active = true
	current_score = inital_score
	reroll_success_probability()

func _physics_process(delta: float) -> void:
	if processing_active:
		if check_score_success():
			current_score += 1
			if current_score >= 2500 * current_lap:
				reroll_success_probability()
				SignalHandler.emit_signal("send_lap_time", item_name, lap_time)
				if current_lap >= max_laps:
					success_probability = randi_range(70, 75)
					unsortable = true
					finish_rect.visible = true
					if !final_lap_time_set:
						final_lap_time = total_lap_time
						final_lap_time_set = true
						animation_player.play("ShowFinish")
				else:
					current_lap += 1
					lap_time = 0.0
			$testvalue.text = str(current_score)
			SignalHandler.emit_signal("update_line_follower", item_name, current_score)
		lap_time += delta
		total_lap_time += delta
	
func reset_values() -> void:
	current_score = 0

func get_lap_time() -> float:
	return lap_time

func check_score_success() -> bool:
	var result: int = randi_range(0, 100)
	return result >= success_probability

func reroll_success_probability() -> void:
	success_probability = randi_range(10, 15)

func update_trailing_seconds(seconds: float) -> void:
	lap_time_offset.text = "+%1.3f" % (seconds + randf_range(0.0, 0.1))

func set_leader_text(text: String) -> void:
	lap_time_offset.text = text

func set_fastest_lap_anim(driver_name: String) -> void:
	if driver_name == item_name:
		current_fastest_lap = true
		animation_player.play("ShowFastestLap")
	else:
		if current_fastest_lap:
			current_fastest_lap = false
			animation_player.play("HideFastestLap")
