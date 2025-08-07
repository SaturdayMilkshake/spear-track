extends Node

@export var target_score: int = 100
@onready var time_label: Node = $TimeLabel

@onready var score_laebl: Node = $ScoreLabel

var score: int = 0
var current_game_seconds: float = 0.0

var game_active: bool = false

func _ready() -> void:
	start_game()
	
func _physics_process(delta: float) -> void:
	#if !game_active:
		#pass
	#else:
		#current_game_seconds += delta
		#time_label.text = str(snapped(current_game_seconds, 0.001))
		#if Input.is_action_just_pressed("ui_select"):
			#score += 1
			#score_laebl.text = str(score)
			#if score >= target_score:
				#end_game()
	pass
		
func start_game() -> void:
	game_active = true
	
func end_game() -> void:
	game_active = false

func restart_game() -> void:
	pass
