extends Node

@export var target_score: int = 100
@export var max_laps: int = 3

@onready var time_label: Node = $TimeLabel
@onready var score_label: Node = $ScoreLabel

@onready var fastest_lap_node: Node = $FastestLap
@onready var fastest_lap_driver: Node = $FastestLap/DriverName
@onready var fastest_lap_time: Node = $FastestLap/LapTime

@onready var lap_label: Node = $LapCounter/LapLabel

var score: int = 0
var current_game_seconds: float = 0.0

var game_active: bool = false

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

var fastest_lap: float = 0.0

func _ready() -> void:
	SignalHandler.connect("send_lap_time", Callable(self, "send_lap_time"))
	SignalHandler.connect("send_leading_lap", Callable(self, "send_leading_lap"))
	start_game()
		
func start_game() -> void:
	game_active = true
	update_lap_counter(current_lap)
	
func end_game() -> void:
	game_active = false

func restart_game() -> void:
	pass

func send_lap_time(driver_name: String, time: float) -> void:
	if fastest_lap <= 0.0:
		fastest_lap_driver.text = driver_names[driver_name]
		fastest_lap_time.text = "%10.3f" % snapped(time, 0.001)
		fastest_lap = time
	elif time < fastest_lap:
		fastest_lap_driver.text = driver_names[driver_name]
		fastest_lap_time.text = "%10.3f" % snapped(time, 0.001)
		fastest_lap = time

func update_lap_counter(lap: int) -> void:
	lap_label.text = "LAP %d / %d" % [lap, max_laps] 

func send_leading_lap(lap_number: int) -> void:
	if lap_number > current_lap:
		current_lap = lap_number
		update_lap_counter(current_lap)
