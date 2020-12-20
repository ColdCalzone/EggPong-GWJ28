extends Control

func _ready():
	for button in get_tree().get_nodes_in_group("menu_button"):
		if button is TextureButton:
			button.connect("menu_button_clicked", self, "on_button_clicked")

func on_button_clicked(slug : String):
	match slug:
		"back": get_tree().change_scene("res://scenes/Titlescreen.tscn")
		_: get_tree().change_scene("res://objects/TransitionIn.tscn")
