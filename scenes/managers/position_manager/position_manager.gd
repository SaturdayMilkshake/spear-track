extends Control

@export var global_position_offset: Vector2 = Vector2.ZERO

@onready var position_container: Node = $PositionContainer

var set_delta: float = 0.0

func _physics_process(delta: float) -> void:
	set_delta = delta

func update_positions() -> void:
	var position_items: Array = position_container.get_children()
	
	position_items.sort_custom(sort_positions)

	var index: int = 0
	position_items[0].set_leader_text("Interval")
	for position_item: Node in position_items:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(position_item, "global_position", Vector2(global_position_offset.x, global_position_offset.y + 48 * (index + 1)), 0.5)
		if index < position_items.size() - 1:
			var compared_item: Node = position_items[index + 1]
			if compared_item:
				compared_item.update_trailing_seconds((position_item.current_score - compared_item.current_score) * set_delta)
		index += 1
		
	SignalHandler.emit_signal("send_leading_lap", position_items[0].current_lap)
	
func sort_positions(original, compared) -> bool:
	if original.unsortable:
		if compared.unsortable:
			return original.final_lap_time < compared.final_lap_time
		else:
			return true
	elif compared.unsortable:
		return false
	else:
		if original.current_score > compared.current_score:
			return true
		else:
			return false
			
func _on_timer_timeout() -> void:
	update_positions()

func set_item_max_laps(laps: int) -> void:
	var position_items: Array = position_container.get_children()
	for position_item: Node in position_items:
		position_item.max_laps = laps
