extends Control

@export var global_position_offset: Vector2 = Vector2.ZERO

@onready var position_container: Node = $PositionContainer

func update_positions() -> void:
	var position_items: Array = position_container.get_children()
	
	position_items.sort_custom(func(original, compared): return original.current_score > compared.current_score)

	var index: int = 0
	for position_item: Node in position_items:
		var tween = create_tween()
		tween.tween_property(position_item, "global_position", Vector2(global_position_offset.x, global_position_offset.y + 48 * (index + 1)), 0.2)
		index += 1
			
func _on_timer_timeout() -> void:
	update_positions()
