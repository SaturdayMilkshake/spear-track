extends Node

@warning_ignore("unused_signal")
signal update_line_follower(driver_name: String, value: int)

signal send_lap_time(driver_name: String, time: float)

signal send_leading_lap(lap_number: int)
