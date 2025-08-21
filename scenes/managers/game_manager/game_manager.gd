extends Node

@export var target_score: int = 100
@export var max_laps: int = 3

@export var current_track_path: Node = null
@export var current_pit_path: Node = null

@onready var position_manager: Node = $PositionManager

@onready var time_label: Node = $TimeLabel
@onready var score_label: Node = $ScoreLabel

@onready var fastest_lap_node: Node = $FastestLap
@onready var fastest_lap_driver: Node = $FastestLap/DriverName
@onready var fastest_lap_time: Node = $FastestLap/LapTime

@onready var lap_label: Node = $LapCounter/LapLabel

@onready var timer: Node = $Timer

@onready var animation_player: Node = $AnimationPlayer

var score: int = 0
var current_game_seconds: float = 0.0

var race_active: bool = false

var current_lap: int = 1

var driver_names: Dictionary = {
	"PIA": "Oscar Piastri",
	"NOR": "Lando Norris",
	"LEC": "Charles Leclerc",
	"HAM": "Lewis Hamilton",
	"RUS": "George Russell",
	"ANT": "Kimi Antonelli",
	"VER": "Max Verstappen",
	"TSU": "Yuki Tsunoda",
	"ALB": "Alexander Albon",
	"SAI": "Carlos Sainz",
	"STR": "Lance Stroll",
	"ALO": "Fernando Alonso",
	"HUL": "Nico Hulkenburg",
	"BOR": "Gabriel Bortoleto",
	"LAW": "Liam Lawson",
	"HAD": "Isack Hadjar",
	"OCO": "Esteban Ocon",
	"BEA": "Oliver Bearman",
	"GAS": "Pierre Gasly",
	"COL": "Franco Colapinto",
}

@export var track_data_preset: Dictionary = {}

var fastest_lap: float = 0.0

func _ready() -> void:
	SignalHandler.connect("send_lap_time", Callable(self, "send_lap_time"))
	SignalHandler.connect("send_leading_lap", Callable(self, "send_leading_lap"))
	SignalHandler.connect("change_line_follower_path", Callable(self, "change_line_follower_path"))
		
func _physics_process(_delta: float) -> void:
	##TODO: fix this hot mess
	if timer.time_left >= 4:
		$RaceLights/TextureRect.visible = true
	elif timer.time_left >= 3:
		$RaceLights/TextureRect.visible = true
		$RaceLights/TextureRect2.visible = true
	elif timer.time_left >= 2:
		$RaceLights/TextureRect.visible = true
		$RaceLights/TextureRect2.visible = true
		$RaceLights/TextureRect3.visible = true
	elif timer.time_left >= 1:
		$RaceLights/TextureRect.visible = true
		$RaceLights/TextureRect2.visible = true
		$RaceLights/TextureRect3.visible = true
		$RaceLights/TextureRect4.visible = true
	elif timer.time_left > 0:
		$RaceLights/TextureRect.visible = true
		$RaceLights/TextureRect2.visible = true
		$RaceLights/TextureRect3.visible = true
		$RaceLights/TextureRect4.visible = true
		$RaceLights/TextureRect5.visible = true
	elif timer.time_left <= 0:
		$RaceLights/TextureRect.visible = false
		$RaceLights/TextureRect2.visible = false
		$RaceLights/TextureRect3.visible = false
		$RaceLights/TextureRect4.visible = false
		$RaceLights/TextureRect5.visible = false
		
func start_race() -> void:
	race_active = true
	position_manager.set_item_max_laps(max_laps)
	position_manager.set_item_processing_status(true)
	update_lap_counter(current_lap)
	position_manager.timer.start()
	
func end_game() -> void:
	race_active = false

func restart_game() -> void:
	pass

func send_lap_time(driver_name: String, time: float) -> void:
	if fastest_lap <= 0.0:
		fastest_lap_driver.text = driver_names[driver_name]
		fastest_lap_time.text = "%10.3f" % [snapped(fmod(time, 60.0), 0.001)]
		fastest_lap = time
		if !animation_player.is_playing():
			animation_player.queue("ShowFastestLap")
		get_tree().call_group("position_item", "set_fastest_lap_anim", driver_name)
	elif time < fastest_lap:
		fastest_lap_driver.text = driver_names[driver_name]
		fastest_lap_time.text = "%10.3f" % [snapped(fmod(time, 60.0), 0.001)]
		fastest_lap = time
		if !animation_player.is_playing():
			animation_player.queue("ShowFastestLap")
		get_tree().call_group("position_item", "set_fastest_lap_anim", driver_name)

func update_lap_counter(lap: int) -> void:
	if lap == max_laps && lap != 1:
		lap_label.text = "FINAL LAP"
	else:
		lap_label.text = "LAP %d / %d" % [lap, max_laps] 

func send_leading_lap(lap_number: int) -> void:
	if lap_number > max_laps:
		pass
	elif lap_number > current_lap:
		current_lap = lap_number
		update_lap_counter(current_lap)

func _on_timer_timeout() -> void:
	start_race()

func change_line_follower_path(driver_name: String, type: String) -> void:
	var race_followers: Array = get_tree().get_nodes_in_group("race_followers")
	var target_node: Node = null
	
	for race_follower: Node in race_followers:
		if race_follower.driver_name == driver_name:
			target_node = race_follower
			break
	
	if target_node != null:
		match type:
			"main":
				target_node.reparent(current_track_path)
				target_node.set_pit_status(false)
			"pit":
				target_node.reparent(current_pit_path)
				target_node.set_pit_status(true)
