extends PathFollow2D

@export var color: Color = Color.WHITE
@export var driver_name: String = ""

@onready var sprite: Node = $Sprite
@onready var label: Node = $Label

func _ready() -> void:
	SignalHandler.connect("update_line_follower", Callable(self, "update_line_follower"))
	sprite.modulate = color
	label.text = driver_name

func update_line_follower(item_name: String, value: int) -> void:
	if item_name == driver_name:
		@warning_ignore("integer_division")
		self.progress_ratio = value / 2500.0
