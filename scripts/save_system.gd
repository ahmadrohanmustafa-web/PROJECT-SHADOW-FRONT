extends Node
class_name ShadowFrontSaveSystem

const SAVE_PATH := "user://shadow_front_save.cfg"
const SAVE_SECTION := "northstar_first_contact"

func load_progress() -> Dictionary:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return {}
	if config.get_value(SAVE_SECTION, "mission_id", "") != "northstar_first_contact":
		return {}
	var checkpoint: Vector3 = config.get_value(SAVE_SECTION, "checkpoint", Vector3(0.0, 0.0, 12.0))
	var objective_index: int = int(config.get_value(SAVE_SECTION, "objective_index", 0))
	return {
		"checkpoint": checkpoint,
		"objective_index": clampi(objective_index, 0, 2),
		"mission_complete": bool(config.get_value(SAVE_SECTION, "mission_complete", false))
	}

func save_progress(objective_index: int, checkpoint: Vector3, mission_complete: bool = false) -> Error:
	var config := ConfigFile.new()
	config.set_value(SAVE_SECTION, "mission_id", "northstar_first_contact")
	config.set_value(SAVE_SECTION, "objective_index", clampi(objective_index, 0, 2))
	config.set_value(SAVE_SECTION, "checkpoint", checkpoint)
	config.set_value(SAVE_SECTION, "mission_complete", mission_complete)
	return config.save(SAVE_PATH)

func clear_progress() -> Error:
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)
	if error != OK and error != ERR_FILE_NOT_FOUND:
		return error
	config.erase_section(SAVE_SECTION)
	return config.save(SAVE_PATH)
