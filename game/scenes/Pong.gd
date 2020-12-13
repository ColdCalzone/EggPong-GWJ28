extends Node2D

const WHOLE_EGG = preload("res://sprites/egg.png")
const BOTTOM_EGG = preload("res://sprites/shell1.png")
const TOP_EGG = preload("res://sprites/shell2.png")

onready var player1_net = $Player1Net
onready var player2_net = $Player2Net
onready var score = $UI/Score
onready var ball = preload("res://objects/Ball.tscn")
onready var shell = preload("res://objects/Shell.tscn")

onready var speedometer_right = $UI/SpeedometerRight
onready var speedometer_left = $UI/SpeedometerLeft

func _ready():
	#OS.window_fullscreen = true
	player1_net.connect("body_entered", self, "score", [2])
	player2_net.connect("body_entered", self, "score", [1])

func score(body, player : int):
	for egg in get_tree().get_nodes_in_group("egg"):
		egg.stop()
	for shell in get_tree().get_nodes_in_group("shell"):
		shell.stop()
	var new_ball = ball.instance()
	score.tick_score(player)
	new_ball.x_direction = abs(player - 2)
	new_ball.first_go = false
	call_deferred("add_child", new_ball)

func split_egg():
	var spawn_location
	for egg in get_tree().get_nodes_in_group("egg"):
		spawn_location = egg.position
		egg.stop()
	var top_shell = shell.instance()
	var bottom_shell = shell.instance()
	
	top_shell.x_direction = 1
	top_shell.first_go = false
	top_shell.position = spawn_location
	top_shell.position.y -= 16
	top_shell.get_node("CollisionBottom").disabled = true
	top_shell.is_shell = true
	top_shell.current_sprite = TOP_EGG
	top_shell.max_speed = 450
	
	bottom_shell.x_direction = -1
	bottom_shell.first_go = false
	bottom_shell.position = spawn_location
	bottom_shell.position.y += 16
	bottom_shell.get_node("CollisionTop").disabled = true
	bottom_shell.is_shell = true
	bottom_shell.current_sprite = BOTTOM_EGG
	bottom_shell.max_speed = 500
	
	call_deferred("add_child", bottom_shell)
	call_deferred("add_child", top_shell)

func _physics_process(delta):
	print(get_tree().get_nodes_in_group("shell").size())
	if get_tree().get_nodes_in_group("egg").size() > 0:
		speedometer_right.update_speed((get_tree().get_nodes_in_group("egg")[0].speed-get_tree().get_nodes_in_group("egg")[0].min_speed)/((get_tree().get_nodes_in_group("egg")[0].max_speed - get_tree().get_nodes_in_group("egg")[0].min_speed)/10))
		speedometer_left.update_speed((get_tree().get_nodes_in_group("egg")[0].speed-get_tree().get_nodes_in_group("egg")[0].min_speed)/((get_tree().get_nodes_in_group("egg")[0].max_speed - get_tree().get_nodes_in_group("egg")[0].min_speed)/10))
	elif get_tree().get_nodes_in_group("shell").size() > 0:
		speedometer_right.update_speed((get_tree().get_nodes_in_group("shell")[0].speed-get_tree().get_nodes_in_group("shell")[0].min_speed)/((get_tree().get_nodes_in_group("shell")[0].max_speed - get_tree().get_nodes_in_group("shell")[0].min_speed)/10))
		if get_tree().get_nodes_in_group("shell").size() > 1:
			speedometer_left.update_speed((get_tree().get_nodes_in_group("shell")[1].speed-get_tree().get_nodes_in_group("shell")[1].min_speed)/((get_tree().get_nodes_in_group("shell")[1].max_speed - get_tree().get_nodes_in_group("shell")[1].min_speed)/10))
	else:
		speedometer_right.update_speed(69)
		speedometer_left.update_speed(69)
