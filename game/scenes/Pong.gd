extends Node2D

const WHOLE_EGG = preload("res://sprites/egg.png")
const BOTTOM_EGG = preload("res://sprites/shell1.png")
const TOP_EGG = preload("res://sprites/shell2.png")

onready var player1_net = $Player1Net
onready var player2_net = $Player2Net
onready var crack = $Crack
onready var ui = $UI
onready var score = $UI/Center/VSort/ScoreCenter/HSort/Score
onready var left_eggs : Array
onready var right_eggs : Array
onready var top_wall = $Ceilng
onready var bot_wall = $Floor
onready var trans_in = $TransitionIn

onready var ball = preload("res://objects/Ball.tscn")
onready var shell = preload("res://objects/Shell.tscn")
onready var egg_insides = preload("res://objects/EggInsides.tscn")
onready var pause = preload("res://objects/PauseOrWin.tscn")

var egg
var shell1
var shell2
var waiting_yolk = null

var left_score : int = 0
var right_score : int = 0

onready var speedometer_right = $UI/Center/VSort/SpeedCenter/Speeds/SpeedometerRight
onready var speedometer_left = $UI/Center/VSort/SpeedCenter/Speeds/SpeedometerLeft

var singleplayer = GameOptions.singleplayer

var target_points = GameOptions.goal

func _ready():
	ui.add_targets(target_points)
	left_eggs = $UI/Center/VSort/ScoreCenter/HSort/EggTargetsLeft.get_children()
	right_eggs = $UI/Center/VSort/ScoreCenter/HSort/EggTargetsRight.get_children()
	ui.toggle_visibility()
	yield(trans_in, "transition_finished")
	ui.toggle_visibility()
	egg = get_node("Ball")
	speedometer_right.align_right()
	#OS.window_fullscreen = true
	player1_net.connect("body_entered", self, "score", [2])
	player2_net.connect("body_entered", self, "score", [1])

func score(body, player : int):
	var insides
	var need_to_add = true
	if not waiting_yolk:
		insides = egg_insides.instance()
	else:
		insides = waiting_yolk
		waiting_yolk = null
		need_to_add = false
	# Magic numbers (320, 180) = half of window size, hard coded because OS.window_size = bad :(
	if need_to_add:
		insides.global_position = body.global_position + Vector2(320, 180)
	var target = left_eggs[0] if not bool(player - 1) else right_eggs[0]
	for egg in get_tree().get_nodes_in_group("egg"):
		egg.stop()
	for shell in get_tree().get_nodes_in_group("shell"):
		shell.stop()
	var new_ball = ball.instance()
	if need_to_add:
		ui.add_child(insides)
	insides.waiting = false
	insides.zoooooooom(target.rect_global_position + Vector2(0, 16))
	#waiting_yolk.zoooooooom(target.rect_global_position + Vector2(0, 16))
	if target_points <= 12:
		left_eggs.remove(0) if not bool(player - 1) else right_eggs.remove(0)
	# b o d g e
	set_physics_process(false)
	yield(insides.tween, "tween_all_completed")
	set_physics_process(true)
	
	score.tick_score(player)
	if player == 1:
		left_score += 1
		if target_points > 12:
			ui.update_count(true, left_score)
	elif player == 2:
		right_score += 1
		if target_points > 12:
			ui.update_count(false, right_score)
	if right_score == target_points or left_score == target_points:
		var win = pause.instance()
		win.state = "win"
		win.winner = int(right_score > left_score) + 1
		win.singleplayer = singleplayer
		ui.add_child(win)
		get_tree().paused = true
	else:
		new_ball.x_direction = abs(player - 2)
		new_ball.first_go = false
		add_child(new_ball)
		egg = new_ball
		if target_points > 12:
			insides.queue_free()

func split_egg():
	var spawn_location
	for egg in get_tree().get_nodes_in_group("egg"):
		spawn_location = egg.global_position
		egg.stop()
	crack.global_position = spawn_location
	crack.play()
	var top_shell = shell.instance()
	var bottom_shell = shell.instance()
	
	var top_direction = round(rand_range(0, 1))
	
	top_shell.x_direction = -1 if top_direction == 0 else 1
	top_shell.first_go = false
	top_shell.global_position = spawn_location
	top_shell.position.y -= 16
	top_shell.get_node("CollisionBottom").disabled = true
	top_shell.is_shell = true
	top_shell.current_sprite = TOP_EGG
	top_shell.max_speed = 500
	top_shell.speed = rand_range(300, 350)
	
	bottom_shell.x_direction = -1 if top_direction == 1 else 1
	bottom_shell.first_go = false
	bottom_shell.global_position = spawn_location
	bottom_shell.position.y += 16
	bottom_shell.get_node("CollisionTop").disabled = true
	bottom_shell.is_shell = true
	bottom_shell.current_sprite = BOTTOM_EGG
	bottom_shell.max_speed = 700
	bottom_shell.speed = rand_range(350, 450)
	
	var insides = egg_insides.instance()
	# Magic numbers (320, 180) = half of window size, hard coded because OS.window_size = bad :(
	insides.global_position = spawn_location + Vector2(320, 180)
	ui.add_child(insides)
	insides.idle(Vector2(0, -85) + Vector2(320, 180))
	waiting_yolk = insides
	call_deferred("add_child", bottom_shell)
	call_deferred("add_child", top_shell)
	shell1 = bottom_shell
	shell2 = top_shell
	

func _physics_process(delta):
	if get_tree().get_nodes_in_group("egg").size() > 0:
		speedometer_right.update_speed((get_tree().get_nodes_in_group("egg")[0].speed-get_tree().get_nodes_in_group("egg")[0].min_speed)/((get_tree().get_nodes_in_group("egg")[0].max_speed - get_tree().get_nodes_in_group("egg")[0].min_speed)/10))
		speedometer_left.update_speed((get_tree().get_nodes_in_group("egg")[0].speed-get_tree().get_nodes_in_group("egg")[0].min_speed)/((get_tree().get_nodes_in_group("egg")[0].max_speed - get_tree().get_nodes_in_group("egg")[0].min_speed)/10))
	elif get_tree().get_nodes_in_group("shell").size() > 0:
		speedometer_right.update_speed((get_tree().get_nodes_in_group("shell")[0].speed-get_tree().get_nodes_in_group("shell")[0].min_speed)/((get_tree().get_nodes_in_group("shell")[0].max_speed - get_tree().get_nodes_in_group("shell")[0].min_speed)/10), "bot")
		if get_tree().get_nodes_in_group("shell").size() > 1:
			speedometer_left.update_speed((get_tree().get_nodes_in_group("shell")[1].speed-get_tree().get_nodes_in_group("shell")[1].min_speed)/((get_tree().get_nodes_in_group("shell")[1].max_speed - get_tree().get_nodes_in_group("shell")[1].min_speed)/10), "top")
	else:
		speedometer_right.update_speed(69)
		speedometer_left.update_speed(69)
	if Input.is_action_just_pressed("pause_game"):
		ui.add_child(pause.instance())
		get_tree().paused = true
