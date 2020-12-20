extends Control

onready var sound = $Sound
onready var other = $Other
onready var sfx_slider = $Sound/Vbox/SFX/VBox/HSlider
onready var music_slider = $Sound/Vbox/Music/VBox/HSlider
onready var fullscreen = $Other/HBoxContainer/VBoxContainer/CheckButton

const CONFIG_PATH : String = "user://settings.cfg"

var config : ConfigFile

func load_config():
	config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err == ERR_FILE_NOT_FOUND:
		err = config.save(CONFIG_PATH)
	if err == OK:
		sfx_slider.value = config.get_value("sound", "sfx_volume", 1)
		fullscreen.pressed = config.get_value("graphics", "fullscreen", false)
		music_slider.value = config.get_value("sound", "music_volume", 1)

func _ready():
	load_config()
	for button in get_tree().get_nodes_in_group("menu_button"):
		if button is TextureButton:
			button.connect("menu_button_clicked", self, "on_button_clicked")
	fullscreen.connect("toggled", self, "save_settings")
	sfx_slider.connect("value_changed", self, "save_settings")
	music_slider.connect("value_changed", self, "save_settings")
	
	if OS.has_feature("web"):
		other.visible = false
		sound.rect_size.y = 360


func on_button_clicked(slug : String):
	match slug:
		"back": get_tree().change_scene("res://scenes/Titlescreen.tscn")
		_: get_tree().change_scene("res://objects/TransitionIn.tscn")

func save_settings(_toggled):
	Settings.save_config(music_slider.value, sfx_slider.value, fullscreen.pressed)
	
