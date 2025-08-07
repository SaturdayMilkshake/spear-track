extends Node2D

@export var health: int = 100

func _on_texture_button_pressed() -> void:
	print(health)
