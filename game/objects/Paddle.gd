extends KinematicBody2D

export var player2_or_ai : bool = false
export var speed : float = 5
var tilt : float = 0.0
var direction : float = 0.0
var previous_ai_output : Array = [0.0, 0.0]

onready var pong = get_parent()

var singleplayer : bool = false

var fresh_rand : bool = false

#var space_state = get_world_2d().direct_space_state

onready var tween = $Tween
onready var sprite = $Sprite

func _ready():
	singleplayer = pong.singleplayer
	if player2_or_ai:
		sprite.flip_h = true

func _physics_process(delta):
	if (singleplayer and not player2_or_ai) or (not singleplayer):
		direction = (Input.get_action_strength("player_1_down") - Input.get_action_strength("player_1_up")) if not player2_or_ai else ((Input.get_action_strength("player_2_down") - Input.get_action_strength("player_2_up")))
		tilt = (Input.get_action_strength("player_1_tilt_right") - Input.get_action_strength("player_1_tilt_left")) if not player2_or_ai else (Input.get_action_strength("player_2_tilt_right") - Input.get_action_strength("player_2_tilt_left"))
		if player2_or_ai:
			sprite.flip_h = true
	else:
		var output = start_action()
		direction = output[0]
		tilt = output[1]
		previous_ai_output = output
	
	position.y += direction * speed
	position.y = clamp(position.y, -112, 112)
	
	tween.interpolate_property(self, "rotation_degrees", rotation_degrees, tilt * 40, 0.1)
	tween.start()

func get_weights(balls : Array):
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
	
	for ball in balls:
		# If the ball is above you...
		if ball:
			if ball.position.y < position.y - 5:
				if ((last_tracked_pos.x <= ball.position.x) if position.x > 0 else (last_tracked_pos.x >= ball.position.x)):
					if previous_ai_output[0] <= 0:
						# then prefer to move up
						up_weight += 1
					last_tracked_pos = ball.position
			# or the ball is below you...
			elif ball.position.y > position.y + 5:
				if ((last_tracked_pos.x <= ball.position.x) if position.x > 0 else (last_tracked_pos.x >= ball.position.x)):
					if previous_ai_output[0] >= 0:
						down_weight += 1
					last_tracked_pos = ball.position
		
			if ((ball.position.x + 64 > position.x) if position.x > 0 else (ball.position.x - 64 > position.x)):
				if ball.position.y > 100:
					left_weight += 100
				elif ball.position.y < -100:
					right_weight += 100
				
			if ball.direction.y < 0:
				if ball.position.y >= position.y + 32:
					left_weight += (-ball.direction.y * 2) + new_random_tilt()[0]
			elif ball.direction.y > 0:
				if ball.position.y <= position.y + 32:
					right_weight += (ball.direction.y * 2) + new_random_tilt()[1]
		
			if ((ball.position.x < position.x - 64) if position.x > 0 else (ball.position.x > position.x + 64)):
				right_weight = 0
				left_weight = 0
				fresh_rand = false
			else:
				if not fresh_rand:
					var output = new_random_tilt()
					right_weight += output[0]
					left_weight += output[1]
					fresh_rand = true
		
		
		#print([left_weight, right_weight])
	
	return [clamp(down_weight - up_weight, -1, 1), stepify(clamp(right_weight - left_weight, -1, 1), 0.01)]

func start_action():
	var balls : Array = []
	for ball in get_tree().get_nodes_in_group("egg"):
		balls.append(ball)
	for shell in get_tree().get_nodes_in_group("shell"):
		balls.append(shell)
	return get_weights(balls)

func new_random_tilt() -> Array:
	return [stepify(rand_range(0, 1), 0.1), stepify(rand_range(0, 1), 0.1)]

#func is_emulated_ball_colliding(position : Vector2):
#	return space_state.intersect_point(position)
