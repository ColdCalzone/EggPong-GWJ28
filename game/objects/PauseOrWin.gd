extends Control

var state : String = "pause"
var winner : int = 0
var singleplayer : bool = false

onready var paused = $Paused/Label
onready var timer = $Timer
onready var tween = $Tween
onready var fade = $ColorRect

func _ready():
	tween.interpolate_property(fade, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 0.7843), 0.5)
	tween.start()
	if state == "pause":
		$CenterButtons/HBoxContainer/MenuButton3.visible = false
		timer.connect("timeout", self, "flip_visible_text")
	if state == "win":
		$CenterButtons/HBoxContainer/MenuButton.visible = false
		paused.text = ("Player " if winner == 1 or singleplayer == false else "AI") + (String(winner) if singleplayer == false else "") + " wins!"
	for button in get_tree().get_nodes_in_group("menu_button"):
		if button is TextureButton:
			button.connect("menu_button_clicked", self, "on_button_clicked")


func on_button_clicked(slug : String):
	get_tree().paused = false
	match slug:
		"quit": get_tree().change_scene("res://scenes/Titlescreen.tscn")
		"rem": get_tree().change_scene("res://scenes/Pong.tscn")
		"res": unpause()
		_: get_tree().change_scene("res://objects/TransitionIn.tscn")

func flip_visible_text():
	paused.visible = !paused.visible

func unpause():
	queue_free()
