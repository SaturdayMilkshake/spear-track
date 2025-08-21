extends Node

@warning_ignore("unused_signal")
signal update_line_follower(driver_name: String, value: float)

@warning_ignore("unused_signal")
signal change_line_follower_path(driver_name: String, type: String)

@warning_ignore("unused_signal")
signal send_lap_time(driver_name: String, time: float)

@warning_ignore("unused_signal")
signal send_leading_lap(lap_number: int)
