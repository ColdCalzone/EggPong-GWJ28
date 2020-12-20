extends Control

onready var camera = $Camera2D
onready var trans_in = $TransitionIn

func _ready():
	for button in get_tree().get_nodes_in_group("menu_button"):
		if button is TextureButton:
			button.connect("menu_button_clicked", self, "on_button_clicked")
	trans_in.connect("transition_finished", self, "hide_transition")

func hide_transition():
	trans_in.visible = false

func on_button_clicked(slug : String):
	match slug:
		"back": get_tree().change_scene("res://scenes/Titlescreen.tscn")
		"next": camera.position.x += 640
		"prev": camera.position.x -= 640
		_: get_tree().change_scene("res://objects/TransitionIn.tscn")
