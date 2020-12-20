extends Node

const CONFIG_PATH = "user://settings.cfg"

var config : ConfigFile

var sfx_volume : float
var music_volume : float
var fullscreen : bool

func load_config():
	config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err == ERR_FILE_NOT_FOUND:
		err = config.save(CONFIG_PATH)
	if err == OK:
		sfx_volume = config.get_value("sound", "sfx_volume", 1)
		music_volume = config.get_value("sound", "music_volume", 1)
		fullscreen = config.get_value("graphics", "fullscreen", false)
		apply_config()

func apply_config():
	OS.set_window_fullscreen(fullscreen)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(sfx_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(music_volume))

func save_config(music_vol : float, sfx_vol : float, is_fullscreen : bool):
	fullscreen = is_fullscreen
	sfx_volume = sfx_vol
	music_volume = music_vol
	apply_config()
	config.set_value("sound", "music_volume", music_vol)
	config.set_value("sound", "sfx_volume", sfx_vol)
	config.set_value("graphics", "fullscreen", is_fullscreen)
	config.save(CONFIG_PATH)
	
