extends Control

@export var global_position_offset: Vector2 = Vector2.ZERO

@onready var position_container: Node = $PositionContainer
@onready var position_count_container: Node = $PositonCountContainer
@onready var timer: Node = $Timer

var item_separation_distance: int = 48

var set_delta: float = 0.0166667

var overtaking_allowed: bool = true
var sorting_disabled: bool = false

func set_initial_item_values(track_data: Dictionary) -> void:
	for position_item: Node in position_container.get_children():
		position_item.lap_step_length = track_data["lap_step_length"]
		position_item.pit_step_length = track_data["pit_step_length"]
		position_item.pit_entry_point = track_data["pit_entry_point"]
		position_item.pit_exit_point = track_data["pit_exit_point"]
		position_item.pit_stoppage_point = track_data["pit_stoppage_point"]

func update_positions() -> void:
	var position_items: Array = position_container.get_children()
	
	position_items.sort_custom(sort_positions)

	var index: int = 0
	if !position_items[0].in_qualifying:
		if position_items[0].unsortable:
			position_items[0].set_leader_text("%d:%06.3f" % [floor(position_items[0].final_lap_time / 60.0), snapped(fmod(position_items[0].final_lap_time, 60.0), 0.001)])
		else:
			position_items[0].set_leader_text("Interval")
	else:
		if position_items[0].self_fastest_lap > 0.0:
			position_items[0].set_leader_text("%d:%06.3f" % [floor(position_items[0].self_fastest_lap / 60.0), snapped(fmod(position_items[0].self_fastest_lap, 60.0), 0.001)])
		
	for position_item: Node in position_items:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(position_item, "global_position", Vector2(global_position_offset.x, global_position_offset.y + item_separation_distance * (index + 1)), 0.5)
		if index < position_items.size() - 1:
			var compared_item: Node = position_items[index + 1]
			if position_item.in_qualifying:
				if position_items[0].self_fastest_lap <= 0.0:
					pass
				else:
					compared_item.update_trailing_seconds(compared_item.self_fastest_lap - position_items[0].self_fastest_lap)
			else:
				if !compared_item.unsortable:
					if position_item.unsortable:
						compared_item.update_trailing_seconds(compared_item.total_lap_time - position_item.final_lap_time)
					else:
						compared_item.update_trailing_seconds((position_item.current_score - compared_item.current_score) * set_delta + randf_range(0.0, 0.01))
				else:
					compared_item.update_trailing_seconds((compared_item.final_lap_time - position_item.final_lap_time))
		index += 1
		
	SignalHandler.emit_signal("send_leading_lap", position_items[0].current_lap)
	
func sort_positions(original, compared) -> bool:
	#TODO: account for overtaking disallowed
	if original.in_qualifying:
		if original.unsortable:
			if compared.unsortable:
				return original.self_fastest_lap < compared.self_fastest_lap
			else:
				if original.current_fastest_lap && original.self_fastest_lap == compared.self_fastest_lap:
					return true
				else:
					return original.self_fastest_lap < compared.self_fastest_lap
		else:
			if original.self_fastest_lap == compared.self_fastest_lap:
				return true
			elif original.self_fastest_lap < compared.self_fastest_lap:
				return true
			else:
				if compared.self_fastest_lap <= 0.0:
					return true
				else:
					return false
	else:
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
	if !sorting_disabled:
		update_positions()

func set_item_max_laps(laps: int) -> void:
	var position_items: Array = position_container.get_children()
	for position_item: Node in position_items:
		position_item.max_laps = laps

func set_item_processing_status(status: bool) -> void:
	var position_items: Array = position_container.get_children()
	for position_item: Node in position_items:
		position_item.processing_active = status

func set_item_compression_status(status: bool) -> void:
	var tween: Tween = create_tween()
	var tween2: Tween = create_tween()
	if status:
		item_separation_distance = 40
		global_position_offset = Vector2(96, 208)
		sorting_disabled = true 
		position_container.size = Vector2(192, 800) #160
		tween.tween_property(position_container, "position", Vector2(32, 216), 0.3)
		tween.tween_callback(func () -> void: sorting_disabled = false)
	else:
		item_separation_distance = 48
		global_position_offset = Vector2(96, 48)
		sorting_disabled = true
		position_container.size = Vector2(192, 960)
		tween.tween_property(position_container, "position", Vector2(32, 64), 0.3)
		tween.tween_callback(func () -> void: sorting_disabled = false)
	
	var position_items: Array = position_container.get_children()
	for position_item: Node in position_items:
		position_item.set_item_compression_status(status)
