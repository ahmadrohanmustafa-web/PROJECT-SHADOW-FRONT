extends Node
class_name ShadowFrontMissionManager

signal objective_changed(index: int, description: String)
signal mission_completed
signal checkpoint_changed(position: Vector3)

var objectives: Array[String] = []
var current_objective_index: int = 0
var checkpoint_position: Vector3 = Vector3.ZERO
var is_active: bool = false
var is_complete: bool = false

func start_mission(objective_list: Array[String], start_checkpoint: Vector3) -> void:
	objectives = objective_list.duplicate()
	current_objective_index = 0
	checkpoint_position = start_checkpoint
	is_active = not objectives.is_empty()
	is_complete = objectives.is_empty()
	if is_active:
		objective_changed.emit(current_objective_index, get_current_objective())
	else:
		mission_completed.emit()

func complete_current_objective() -> void:
	if not is_active or is_complete:
		return
	current_objective_index += 1
	if current_objective_index >= objectives.size():
		is_active = false
		is_complete = true
		mission_completed.emit()
		return
	objective_changed.emit(current_objective_index, get_current_objective())

func set_checkpoint(new_position: Vector3) -> void:
	checkpoint_position = new_position
	checkpoint_changed.emit(checkpoint_position)

func get_current_objective() -> String:
	if is_complete:
		return "Mission complete"
	if current_objective_index < 0 or current_objective_index >= objectives.size():
		return ""
	return objectives[current_objective_index]

func get_objective_counter() -> String:
	if is_complete:
		return "ALL OBJECTIVES COMPLETE"
	return "OBJECTIVE %d / %d" % [current_objective_index + 1, objectives.size()]
