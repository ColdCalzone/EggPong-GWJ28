extends KinematicBody2D

export var player2_or_ai : bool = false
export var speed : float = 5
var tilt : float = 0.0

onready var tween = $Tween

func _physics_process(delta):
	var direction = (Input.get_action_strength("player_1_down") - Input.get_action_strength("player_1_up")) if not player2_or_ai else (Input.get_action_strength("player_2_down") - Input.get_action_strength("player_2_up"))
	tilt = (Input.get_action_strength("player_1_tilt_right") - Input.get_action_strength("player_1_tilt_left")) if not player2_or_ai else (Input.get_action_strength("player_2_tilt_right") - Input.get_action_strength("player_2_tilt_left"))
	
	position.y += direction * speed
	position.y = clamp(position.y, -112, 112)
	
	tween.interpolate_property(self, "rotation_degrees", rotation_degrees, tilt * 40, 0.1)
	tween.start()
