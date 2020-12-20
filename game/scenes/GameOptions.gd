extends Control

onready var goal = $CenterOptions/HBox/Goal
onready var singleplayer = $CenterOptions/HBox/SinglePlayer

func _ready():
	for button in get_tree().get_nodes_in_group("menu_button"):
		if button is TextureButton:
			button.connect("menu_button_clicked", self, "on_button_clicked")
	goal.connect("value_changed", self, "change_goal")
	singleplayer.connect("toggled", self, "change_singleplayer")

func on_button_clicked(slug : String):
	match slug:
		"back": get_tree().change_scene("res://scenes/Titlescreen.tscn")
		"start": get_tree().change_scene("res://scenes/Pong.tscn")
		_: get_tree().change_scene("res://objects/TransitionIn.tscn")

func change_goal(value : int):
	GameOptions.goal = value

func change_singleplayer(value : bool):
	GameOptions.singleplayer = value
