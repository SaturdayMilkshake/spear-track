extends PathFollow2D

@export var color: Color = Color.WHITE
@export var driver_name: String = ""

@onready var sprite: Node = $Display/Sprite
@onready var label: Node = $Display/Label

func _ready() -> void:
	SignalHandler.connect("update_line_follower", Callable(self, "update_line_follower"))
	sprite.modulate = color
	label.text = driver_name

func update_line_follower(item_name: String, value: float) -> void:
	if item_name == driver_name:
		@warning_ignore("integer_division")
		self.progress_ratio = value

func set_pit_status(status: bool) -> void:
	if status:
		var tween: Tween = create_tween()
		tween.tween_property($Display, "scale", Vector2(0.7, 0.7), 1.0)
	else:
		var tween: Tween = create_tween()
		tween.tween_property($Display, "scale", Vector2(1.0, 1.0), 1.0)
