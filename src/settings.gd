extends Node

const SETTINGS_PATH = "user://settings.cfg"

var settings = {}


func _ready():
	load_settings()


func load_settings():
	# Create default settings if file doesn't exist
	if not FileAccess.file_exists(SETTINGS_PATH):
		settings = {"vol_master": 40, "vol_music": 100, "vol_sfx": 100}
		save_settings()
	else:
		var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		settings = file.get_var()
		file.close()


func save_settings():
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	file.store_var(settings)
	file.close()
