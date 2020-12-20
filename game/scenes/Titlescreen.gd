extends Control

onready var buttons = $Buttonizer9000/Buttons
onready var quit = $Buttonizer9000/Buttons/quit

func _ready():
	if OS.has_feature("web"):
		quit.modulate = Color(0.5, 0.5, 0.5, 1)
		quit.disabled = true
	Settings.load_config()
	randomize()
	for button in buttons.get_children():
		if button is TextureButton:
			button.connect("menu_button_clicked", self, "on_button_clicked")

func on_button_clicked(slug : String):
	match slug:
		"play": get_tree().change_scene("res://scenes/GameOptions.tscn")
		"settings": get_tree().change_scene("res://scenes/Settings.tscn")
		"credits": get_tree().change_scene("res://scenes/Credits.tscn")
		"help": get_tree().change_scene("res://scenes/Help.tscn")
		"quit": get_tree().quit(0)
		_: get_tree().change_scene("res://objects/TransitionIn.tscn")
