extends Node

const SETTINGS_PATH = "user://settings"

var settings = {}

@export var default_settings = {"vol_master": 40, "vol_music": 100, "vol_sfx": 100}


func _ready():
	load_settings()


func load_settings():
	# Create default settings if file doesn't exist
	if not FileAccess.file_exists(SETTINGS_PATH):
		print("Settings file not found, creating new one")
		settings = default_settings
		save_settings()
	else:
		var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		settings = file.get_var()
		file.close()


func save_settings():
	print("Saving settings")
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	file.store_var(settings)
	file.close()
