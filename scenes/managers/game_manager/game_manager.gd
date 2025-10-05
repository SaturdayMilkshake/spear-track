extends Node

@export var target_score: int = 100
@export var max_laps: int = 3

@export var current_track_path: Node = null
@export var current_pit_path: Node = null

@onready var position_manager: Node = $PositionManager

@onready var track_image: Node = $TrackImage

@onready var fastest_lap_node: Node = $FastestLap
@onready var fastest_lap_driver: Node = $FastestLap/DriverName
@onready var fastest_lap_time: Node = $FastestLap/LapTime

@onready var lap_label: Node = $LapCounter/LapLabel

@onready var start_timer: Node = $StartTimer

@onready var animation_player: Node = $AnimationPlayer

@onready var race_followers: Node = $RaceFollowers

@onready var race_paths: Node = $RacePaths

@onready var track_data: Node = $TrackData
@onready var driver_data: Node = $DriverData

var score: int = 0
var current_game_seconds: float = 0.0

var race_active: bool = false

var current_lap: int = 1

@export var track_data_preset: Dictionary = {}

@export var track_string: String = ""

var fastest_lap: float = 0.0

# Race Presets
var free_practice: bool = false
var qualifying: bool = false
var grand_prix: bool = false

# Race Statuses
var formation_lap: bool = false
var safety_car_active: bool = false
var virtual_safety_car_active: bool = false

var overtakes_allowed: bool = true

func _ready() -> void:
	SignalHandler.connect("send_lap_time", Callable(self, "send_lap_time"))
	SignalHandler.connect("send_leading_lap", Callable(self, "send_leading_lap"))
	SignalHandler.connect("change_line_follower_path", Callable(self, "change_line_follower_path"))
	set_initial_race_start_values(track_data.track_data_collection[track_string])
	set_initial_track_paths(track_string)
	set_race_follower_paths()
		
func _physics_process(_delta: float) -> void:
	##TODO: fix this hot mess
	if start_timer.time_left >= 4:
		$RaceLights/TextureRect.visible = true
	elif start_timer.time_left >= 3:
		$RaceLights/TextureRect.visible = true
		$RaceLights/TextureRect2.visible = true
	elif start_timer.time_left >= 2:
		$RaceLights/TextureRect.visible = true
		$RaceLights/TextureRect2.visible = true
		$RaceLights/TextureRect3.visible = true
	elif start_timer.time_left >= 1:
		$RaceLights/TextureRect.visible = true
		$RaceLights/TextureRect2.visible = true
		$RaceLights/TextureRect3.visible = true
		$RaceLights/TextureRect4.visible = true
	elif start_timer.time_left > 0:
		$RaceLights/TextureRect.visible = true
		$RaceLights/TextureRect2.visible = true
		$RaceLights/TextureRect3.visible = true
		$RaceLights/TextureRect4.visible = true
		$RaceLights/TextureRect5.visible = true
	elif start_timer.time_left <= 0:
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
	
func set_race_follower_paths() -> void:
	for race_follower: Node in race_followers.get_children():
		race_follower.reparent(current_track_path)

func send_lap_time(driver_name: String, time: float) -> void:
	if fastest_lap <= 0.0:
		fastest_lap_driver.text = driver_data.driver_names[driver_name]
		fastest_lap_time.text = "%d:%06.3f" % [floor(time / 60.0), snapped(fmod(time, 60.0), 0.001)]
		fastest_lap = time
		animation_player.play("ShowFastestLap")
		get_tree().call_group("position_item", "set_fastest_lap_anim", driver_name)
	elif time < fastest_lap:
		fastest_lap_driver.text = driver_data.driver_names[driver_name]
		fastest_lap_time.text = "%d:%06.3f" % [floor(time / 60.0), snapped(fmod(time, 60.0), 0.001)]
		fastest_lap = time
		animation_player.play("ShowFastestLap")
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

func _on_start_timer_timeout() -> void:
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

func activate_safety_car() -> void:
	safety_car_active = true
	
func activate_virtual_safety_car() -> void:
	virtual_safety_car_active = true

func set_initial_race_start_values(track_data: Dictionary) -> void:
	track_image.texture = load(track_data["track_image"])
	max_laps = track_data["total_laps"]
	position_manager.set_initial_item_values(track_data)

func set_initial_track_paths(track: String) -> void:
	var paths: Node = race_paths.get_node(track)
	if paths:
		current_track_path = paths.get_node("Track")
		current_pit_path = paths.get_node("Pit")
