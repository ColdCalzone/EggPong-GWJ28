extends Control

onready var label = $Readout

func update_speed(speed : float):
	label.text = String(round(speed))
	label.set("custom_colors/font_color", Color(1, lerp(1, 0, max(0, speed-4)/6.0), lerp(1, 0, max(0, speed-4)/6.0)))
