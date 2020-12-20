extends KinematicBody2D

export var player2_or_ai : bool = false
export var speed : float = 5
var tilt : float = 0.0
var direction : float = 0.0
var check_bounces_timer : float = 1.0
#var previous_ai_output : Array = [0.0, 0.0]

onready var pong = get_parent()

var singleplayer : bool = false

var fresh_rand : bool = false

var space_state

onready var tween = $Tween
onready var sprite = $Sprite
var last_tracked_pos

func _ready():
	randomize()
	singleplayer = pong.singleplayer
	if player2_or_ai:
		sprite.flip_h = true

func _physics_process(delta):
	space_state = get_world_2d().direct_space_state
	if (singleplayer and not player2_or_ai) or (not singleplayer):
		direction = (Input.get_action_strength("player_1_down") - Input.get_action_strength("player_1_up")) if not player2_or_ai else ((Input.get_action_strength("player_2_down") - Input.get_action_strength("player_2_up")))
		tilt = (Input.get_action_strength("player_1_tilt_right") - Input.get_action_strength("player_1_tilt_left")) if not player2_or_ai else (Input.get_action_strength("player_2_tilt_right") - Input.get_action_strength("player_2_tilt_left"))
		if player2_or_ai:
			sprite.flip_h = true
	else:
		var output = get_weights(get_tree().get_nodes_in_group("egg") + get_tree().get_nodes_in_group("shell"), delta)
		direction = output[0]
		tilt = output[1]
		#previous_ai_output = output
	
	position.y += direction * speed
	position.y = clamp(position.y, -112, 112)
	
	tween.interpolate_property(self, "rotation_degrees", rotation_degrees, tilt * 40, 0.1)
	tween.start()

func get_weights(balls : Array, delta : float):
	# The weight to move upwards
	var up_weight : float = 0.0
	# The weight to move downwards
	var down_weight : float = 0.0
	# The weight to tilt right
	var right_weight : float = 0.0
	# The weight to tilt left
	var left_weight : float = 0.0
	# The last pos, helps to priotize which shell to follow
	
	check_bounces_timer -= delta
	
	for ball in balls:
		# If the ball is above you...
		if not last_tracked_pos:
			last_tracked_pos = ball
		elif ((last_tracked_pos.position.x <= ball.position.x) if position.x > 0 else (last_tracked_pos.position.x >= ball.position.x)):
			last_tracked_pos = ball
		
		if ball:
			if last_tracked_pos.position.y < position.y - 5:
				#if previous_ai_output[0] <= 0:
				# then prefer to move up
				up_weight += 1
			# or the ball is below you...
			elif last_tracked_pos.position.y > position.y + 5:
				#if previous_ai_output[0] >= 0:
				down_weight += 1
		
			if ((last_tracked_pos.position.x + 128 > position.x) if position.x > 0 else (last_tracked_pos.position.x - 128 > position.x)):
				if last_tracked_pos.position.y > 100:
					left_weight += 100
				elif last_tracked_pos.position.y < -100:
					right_weight += 100
				
			if last_tracked_pos.direction.y < 0:
				if last_tracked_pos.position.y >= position.y + 32:
					left_weight += (-last_tracked_pos.direction.y * 2) + new_random_tilt()[0]
			elif last_tracked_pos.direction.y > 0:
				if last_tracked_pos.position.y <= position.y + 32:
					right_weight += (last_tracked_pos.direction.y * 2) + new_random_tilt()[1]
		
			if ((last_tracked_pos.position.x < position.x - 128) if position.x > 0 else (last_tracked_pos.position.x > position.x + 128)):
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

func new_random_tilt() -> Array:
	var rand_one = stepify(rand_range(0, 2), 0.05)
	randomize()
	var rand_two = stepify(rand_range(0, 2), 0.05)
	return [rand_one, rand_two]

#func is_emulated_ball_colliding(position : Vector2):
#	return space_state.intersect_point(position)
