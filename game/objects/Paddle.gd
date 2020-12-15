extends KinematicBody2D

export var player2_or_ai : bool = false
export var speed : float = 5
var tilt : float = 0.0
var direction : float = 0.0

onready var pong = get_parent()

var singleplayer : bool = false

onready var tween = $Tween

func _ready():
	singleplayer = pong.singleplayer

func _physics_process(delta):
	if (singleplayer and not player2_or_ai) or (not singleplayer):
		direction = (Input.get_action_strength("player_1_down") - Input.get_action_strength("player_1_up")) if not player2_or_ai else ((Input.get_action_strength("player_2_down") - Input.get_action_strength("player_2_up")))
		tilt = (Input.get_action_strength("player_1_tilt_right") - Input.get_action_strength("player_1_tilt_left")) if not player2_or_ai else (Input.get_action_strength("player_2_tilt_right") - Input.get_action_strength("player_2_tilt_left"))
	else:
		var output = start_action()
		direction = output[0]
		tilt = output[1]
	
	position.y += direction * speed
	position.y = clamp(position.y, -112, 112)
	
	tween.interpolate_property(self, "rotation_degrees", rotation_degrees, tilt * 40, 0.1)
	tween.start()

func determine_action(balls_pos : Array, balls_direction : Array, balls_distance_from_walls : Array):
	# The weight to move upwards
	var up_weight : float = 0.0
	# The weight to move downwards
	var down_weight : float = 0.0
	# The weight to tilt right
	var right_weight : float = 0.0
	# The weight to tilt left
	var left_weight : float = 0.0
	# The last pos, helps to priotize which shell to follow
	var last_tracked_pos : Vector2 = Vector2(-300, 0)
	
	for ball_pos in balls_pos:
		if ball_pos.y < position.y - 0.2:
			if position.y - 0.2 - ball_pos.y < 1:
				if last_tracked_pos.x < ball_pos.x:
					up_weight += 0.5
					last_tracked_pos = ball_pos
			else:
				if last_tracked_pos.x < ball_pos.x:
					up_weight += 1
					last_tracked_pos = ball_pos
		elif ball_pos.y > position.y + 0.2:
			if ball_pos.y - position.y + 0.2 < 1:
				if last_tracked_pos.x < ball_pos.x:
					down_weight += 0.5
					last_tracked_pos = ball_pos
			else:
				if last_tracked_pos.x < ball_pos.x:
					down_weight += 1
					last_tracked_pos = ball_pos
		
		if ball_pos.x + 32 > position.x:
			if ball_pos.y > 100:
				left_weight += 10
			elif ball_pos.y < -100:
				right_weight += 10
			
		for ball_direction in balls_direction:
			if ball_direction.y < 0:
				left_weight += (1 * ball_direction.y) * 4
			elif ball_direction.y > 0:
				right_weight += (1 * -ball_direction.y) * 4
	
	return [clamp(down_weight - up_weight, -1, 1), clamp(right_weight - left_weight, -1, 1)]

func start_action():
	var balls_pos : Array = []
	var balls_direction : Array = []
	var balls_distance_from_wall : Array = []
	for ball in get_tree().get_nodes_in_group("egg"):
		balls_pos.append(ball.position)
		balls_direction.append(ball.direction)
		if ball.position.y < 0:
			balls_distance_from_wall.append(ball.position - pong.top_wall.position)
		if ball.position.y > 0:
			balls_distance_from_wall.append(pong.bot_wall.position - ball.position)
	for shell in get_tree().get_nodes_in_group("shell"):
		balls_pos.append(shell.position)
		balls_direction.append(shell.direction)
		if shell.position.y < 0:
			balls_distance_from_wall.append(shell.position - pong.top_wall.position)
		if shell.position.y > 0:
			balls_distance_from_wall.append(pong.bot_wall.position - shell.position)
	return determine_action(balls_pos, balls_direction, balls_distance_from_wall)
