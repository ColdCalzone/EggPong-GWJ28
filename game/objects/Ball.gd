extends KinematicBody2D

const WHOLE_SPRITE = preload("res://sprites/egg.png")
const BOTTOM_SPRITE = preload("res://sprites/shell1.png")
const TOP_SPRITE = preload("res://sprites/shell2.png")

var current_sprite = WHOLE_SPRITE

const BLEEPS = [preload("res://sounds/blips_01.wav"), preload("res://sounds/blips_02.wav"), preload("res://sounds/blips_03.wav")]

var bleep_timer : float = 0.5
var bleeping : bool = false

onready var pong = get_parent()
onready var sprite = $Sprite
onready var sound = $Bleeps
export var direction : Vector2 = Vector2.ZERO
export var speed : float = 300
export var max_speed : float = 800
export var min_speed : float = speed
export var x_direction : int = -1
export var first_go : bool = true
export var is_shell : bool = false
export var split_timer : float = 0.5
var rotation_per_frame : float = 1.0
var contact_time : int = 1
var last_collision : String
var previous_positions : Array = [Vector2.ZERO, Vector2.ZERO]

func _ready():
	randomize()
	sprite.texture = current_sprite
	if not is_shell: yield(get_tree().create_timer(1), "timeout")
	if first_go:
		x_direction = round(rand_range(0, 1))
		randomize()
	if x_direction == 0: x_direction = -1
	direction.x = x_direction
	# Testing line PLS DELETE LATER.
	#direction = Vector2(0, 1)

func _physics_process(delta : float):
	sprite.texture = current_sprite
	var collision = move_and_collide(direction.normalized() * speed * delta)
	#print(direction)
	if collision:
		if bleep_timer > 0:
			sound.stream = BLEEPS[rand_range(0, BLEEPS.size() - 1)]
			sound.play()
			bleeping = true
		else:
			randomize()
			bleep_timer = 0.5
			bleeping = false
		if bleeping: bleep_timer -= delta
		if direction.x > 0:
			rotation_per_frame += (ceil(direction.x) * contact_time)
		if direction.x < 0:
			rotation_per_frame += (floor(direction.x) * contact_time)
		contact_time += 1
		previous_positions[0] = previous_positions[1]
		previous_positions[1] = position
		speed += 10
		speed = clamp(speed, -max_speed, max_speed)
		rotation_degrees += rotation_per_frame
		if collision.collider.is_in_group("floor_ceil"):
			last_collision = "floor_ceil"
			direction = direction.bounce(collision.normal)
		if collision.collider.is_in_group("paddle"):
			last_collision = "paddle"
			direction = direction.bounce(collision.normal)
			if direction.x < 0:
				direction.x = max(direction.x, -0.4)
			if direction.x > 0:
				direction.x = max(direction.x, 0.4)
		if previous_positions[0] == previous_positions[1] and previous_positions[1] == position:
			pong.score(self, int(position.x < 0) + 1)
	else:
		contact_time = 1
		rotation_degrees += rotation_per_frame
	if speed == max_speed and not is_shell:
		split_timer -= delta
	if split_timer <= 0:
		pong.split_egg()

func stop():
	set_physics_process(false)
	queue_free()
