extends Control

@export var icon_texture: Texture = null
@export var item_name: String = ""
@export var inital_score: int = 0

@export var lap_step_length: float = 2500.0
@export var pit_step_length: float = 600.0

@export var pit_entry_point: int = 1
@export var pit_stoppage_point: int = 1
@export var pit_exit_point: int = 1

@export var max_pit_stops: int = 2

@export var driver_performace_weight: int = 1

@onready var icon: Node = $Icon
@onready var position_name: Node = $PositionName
@onready var data_displayer: Node = $DataDisplayer
@onready var finish_rect: Node = $FinishRect
@onready var fastest_lap_rect: Node = $FastestLapRect
@onready var lap_time_offset: Node = $LapTimeOffset

@onready var pit_timer: Node = $PitTimer

@onready var animation_player: Node = $AnimationPlayer

var success_probability: int = 100

var current_score: int = 0
var current_lap: int = 1
var max_laps: int = 1

var pit_score: int = 0

var tire_type: String = "Soft"
var tire_age: int = 0

var lap_time: float = 0.0
var total_lap_time: float = 0.0
var final_lap_time: float = 0.0
var pit_time: float = 0.0
var pit_stoppage_time: float = 0.0

var processing_active: bool = false
var unsortable: bool = false
var final_lap_time_set: bool = false
var current_fastest_lap: bool = false

var pitting_next_lap: bool = false
var in_pit: bool = false
var pitted: bool = false

var pit_stops: int = 0

enum DriverState {
	NORMAL,
	IN_PIT,
	PITTING,
	FINISHED
}

var driver_state: int = DriverState.NORMAL

func _ready() -> void:
	current_lap = 1
	icon.texture = icon_texture
	position_name.text = item_name
	current_score = inital_score
	reroll_success_probability()
	SignalHandler.emit_signal("update_line_follower", item_name, current_score / lap_step_length)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("show_pit_stops"):
		show_data("pit_stops")
	elif Input.is_action_just_pressed("show_laps"):
		show_data("laps")
	elif Input.is_action_just_pressed("show_tire_age"):
		show_data("tire_age")
	
	if processing_active:
		if check_score_success():
			if in_pit:
				pit_score += 1
				if !pitted:
					if pit_score % int(pit_step_length) >= pit_stoppage_point:
						var pit_time_result: float = randf_range(1.8, 2.8)
						pit_timer.start(pit_time_result)
						success_probability = 1000
				else:
					if pit_score >= pit_step_length:
						current_lap += 1
						tire_age = 0
						lap_time = 0.0
						current_score = (current_lap - 1) * lap_step_length + pit_exit_point
						in_pit = false
						pitted = false
						pit_score = 0
						reroll_success_probability()
						SignalHandler.emit_signal("change_line_follower_path", item_name, "main")
			else:
				current_score += 1
				if check_weighted_score_success():
					current_score += 1
				
			if pitting_next_lap:
				if current_score % int(lap_step_length) >= pit_entry_point:
					success_probability = randi_range(7, 10) + tire_age
					in_pit = true
					pitting_next_lap = false
					pit_item()
			if current_score >= lap_step_length * current_lap:
				current_score += 1
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
					tire_age += 1
					lap_time = 0.0
					if !pitting_next_lap:
						if check_pit_chance_success():
							pitting_next_lap = true
		lap_time += delta
		total_lap_time += delta
		
	if !in_pit:
		SignalHandler.emit_signal("update_line_follower", item_name, current_score / lap_step_length)
	else:
		SignalHandler.emit_signal("update_line_follower", item_name, pit_score / pit_step_length)
	
func reset_values() -> void:
	current_score = 0

func get_lap_time() -> float:
	return lap_time

func check_score_success() -> bool:
	var result: int = randi_range(0, 100)
	return result >= success_probability
	
func check_pit_chance_success() -> bool:
	var result: int = randi_range(0, 100)
	if tire_age < 3:
		return false
	elif max_laps - current_lap <= 3:
		return false
	elif tire_age >= 25:
		return true
	elif pit_stops >= max_pit_stops:
		return false
	else:
		return result <= 1 + (tire_age - 3)

func reroll_success_probability() -> void:
	success_probability = randi_range(5, 10) + tire_age

func update_trailing_seconds(seconds: float) -> void:
	if !in_pit:
		lap_time_offset.text = "+%1.3f" % seconds
	else:
		lap_time_offset.text = "IN PIT"

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

func pit_item() -> void:
	SignalHandler.emit_signal("change_line_follower_path", item_name, "pit")

func _on_pit_timer_timeout() -> void:
	pitted = true
	pit_stops += 1
	success_probability = randi_range(30, 32)

func check_weighted_score_success() -> bool:
	var result: int = randi_range(0, 50)
	return result <= driver_performace_weight

func show_data(type: String) -> void:
	match type:
		"laps":
			data_displayer.text = str(current_lap)
		"pit_stops":
			data_displayer.text = str(pit_stops)
		"tire_age":
			data_displayer.text = str(tire_age)
	animation_player.play("ShowDataDisplayer")
