extends Node

const SETTINGS_PATH = "user://settings"

var settings = {}

@export var default_settings = {"vol_master": 0.4, "vol_music": 1.0, "vol_sfx": 1.0}


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

	# Apply sound settings to the bus.
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"), linear_to_db(settings["vol_master"])
	)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"), linear_to_db(settings["vol_music"])
	)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Effects"), linear_to_db(settings["vol_sfx"])
	)


func save_settings():
	print("Saving settings")
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	file.store_var(settings)
	file.close()
