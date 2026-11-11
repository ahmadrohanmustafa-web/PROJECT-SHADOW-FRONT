extends Node3D

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")

const CONCRETE := Color(0.20, 0.23, 0.24)
const DARK_CONCRETE := Color(0.12, 0.15, 0.17)
const WARM_METAL := Color(0.42, 0.34, 0.25)
const PALE_METAL := Color(0.36, 0.40, 0.41)
const ACCENT := Color(0.72, 0.48, 0.20)

var mission_status_label: Label
var player: ShadowFrontPlayer
var companion: ShadowFrontCompanion
var mission_manager: ShadowFrontMissionManager
var save_system: ShadowFrontSaveSystem
var saved_mission_complete: bool = false
var world_environment_node: WorldEnvironment
var pause_menu: ShadowFrontPauseMenu
var interaction_prompt_label: Label
var squad_dialogue_label: Label
var squad_dialogue_time_remaining: float = 0.0
var mission_event_label: Label
var mission_event_time_remaining: float = 0.0
var navigation_label: Label
var navigation_refresh_time: float = 0.0

func _ready() -> void:
	_create_environment()
	_create_level()
	_create_player()
	_create_hud()
	_create_mission_manager()
	_create_objective_triggers()
	_create_checkpoint_trigger()
	_create_companion()
	_create_pause_menu()
	_create_deployment_briefing()

func _create_environment() -> void:
	var world_environment := WorldEnvironment.new()
	world_environment_node = world_environment
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.30, 0.38, 0.43)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.58, 0.63, 0.67)
	environment.ambient_light_energy = 0.72
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.48, 0.55, 0.58)
	environment.fog_density = 0.006
	world_environment.environment = environment
	add_child(world_environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -32.0, 0.0)
	sun.light_color = Color(1.0, 0.88, 0.72)
	sun.light_energy = 0.82
	sun.shadow_enabled = false
	add_child(sun)

func _create_level() -> void:
	# A compact fictional industrial terminal. Geometry is deliberately
	# primitive and static so the prototype remains light on older GPUs.
	_add_box("Terminal yard", Vector3(0.0, -0.15, -5.0), Vector3(42.0, 0.3, 48.0), CONCRETE)
	_add_box("North perimeter", Vector3(0.0, 2.0, -29.0), Vector3(42.0, 4.0, 0.6), DARK_CONCRETE)
	_add_box("West perimeter", Vector3(-21.0, 2.0, -5.0), Vector3(0.6, 4.0, 48.0), DARK_CONCRETE)
	_add_box("East perimeter", Vector3(21.0, 2.0, -5.0), Vector3(0.6, 4.0, 48.0), DARK_CONCRETE)

	# Main warehouse façade and its open loading bays.
	_add_box("Warehouse left wing", Vector3(-10.0, 3.0, -20.0), Vector3(10.0, 6.0, 8.0), PALE_METAL)
	_add_box("Warehouse right wing", Vector3(10.0, 3.0, -20.0), Vector3(10.0, 6.0, 8.0), PALE_METAL)
	_add_box("Warehouse roof", Vector3(0.0, 6.15, -20.0), Vector3(11.0, 0.3, 8.0), DARK_CONCRETE)
	_add_box("Loading bay header", Vector3(0.0, 5.0, -15.8), Vector3(10.0, 1.0, 0.5), WARM_METAL)
	_add_box("Loading bay divider", Vector3(0.0, 2.5, -15.8), Vector3(0.35, 4.0, 0.5), DARK_CONCRETE)

	# A low service building gives the yard a second readable landmark.
	_add_box("Service building", Vector3(14.0, 1.8, 1.0), Vector3(7.0, 3.6, 8.0), WARM_METAL)
	_add_box("Service roof", Vector3(14.0, 3.75, 1.0), Vector3(7.4, 0.3, 8.4), DARK_CONCRETE)
	_add_box("Service door", Vector3(10.4, 1.1, -3.05), Vector3(1.4, 2.2, 0.12), DARK_CONCRETE)

	# Yard markings are visual-only thin meshes, not extra collision bodies.
	for lane_x in [-7.0, 7.0]:
		_add_box("Painted lane line", Vector3(lane_x, 0.012, -4.0), Vector3(0.12, 0.02, 23.0), ACCENT, false)
	for stripe_z in [-12.0, -8.0, -4.0, 0.0, 4.0]:
		_add_box("Loading stripe", Vector3(0.0, 0.014, stripe_z), Vector3(4.0, 0.02, 0.10), Color(0.72, 0.68, 0.54), false)

	# Static cargo stacks and low platforms create varied traversal spaces.
	_add_box("Cargo container A", Vector3(-12.0, 1.25, -5.0), Vector3(5.0, 2.5, 3.0), Color(0.28, 0.35, 0.35))
	_add_box("Cargo container B", Vector3(-12.0, 3.85, -5.0), Vector3(5.0, 2.5, 3.0), Color(0.34, 0.39, 0.37))
	_add_box("Cargo container C", Vector3(5.0, 1.1, 7.0), Vector3(4.0, 2.2, 3.0), Color(0.35, 0.30, 0.25))
	_add_box("Low service platform", Vector3(-2.0, 0.35, -3.0), Vector3(3.0, 0.7, 2.0), PALE_METAL)
	_add_box("Raised loading platform", Vector3(0.0, 0.55, -11.0), Vector3(6.0, 1.1, 2.0), WARM_METAL)

	# A simple overhead gantry frames the route toward the warehouse.
	_add_box("Gantry left support", Vector3(-5.5, 3.0, -9.0), Vector3(0.35, 6.0, 0.35), DARK_CONCRETE)
	_add_box("Gantry right support", Vector3(5.5, 3.0, -9.0), Vector3(0.35, 6.0, 0.35), DARK_CONCRETE)
	_add_box("Gantry crossbeam", Vector3(0.0, 5.8, -9.0), Vector3(11.0, 0.35, 0.5), WARM_METAL)

	# Low-cost light poles are unlit props; the sun provides the scene lighting.
	for pole_x in [-17.0, 17.0]:
		_add_box("Yard light pole", Vector3(pole_x, 3.0, -8.0), Vector3(0.16, 6.0, 0.16), DARK_CONCRETE)
		_add_box("Yard light arm", Vector3(pole_x * 0.94, 5.8, -8.0), Vector3(1.0, 0.14, 0.14), PALE_METAL)

	_add_label("NORTHSTAR TERMINAL", Vector3(0.0, 4.1, -15.45), 28, Color(0.88, 0.83, 0.69))
	_add_label("LOADING YARD  /  SECTOR 04", Vector3(-14.0, 2.8, 10.0), 18, Color(0.84, 0.78, 0.62))
	_add_box("Crouch passage top", Vector3(-4.0, 1.8, 5.0), Vector3(4.0, 0.35, 2.0), WARM_METAL)
	_add_box("Crouch passage left", Vector3(-5.85, 0.9, 5.0), Vector3(0.3, 1.8, 2.0), WARM_METAL)
	_add_box("Crouch passage right", Vector3(-2.15, 0.9, 5.0), Vector3(0.3, 1.8, 2.0), WARM_METAL)
	_add_label("OBJECTIVE  →", Vector3(0.0, 3.0, -13.9), 24, Color(1.0, 0.76, 0.36))
	_add_box("Data terminal pedestal", Vector3(0.0, 0.55, -24.0), Vector3(1.5, 1.1, 0.9), DARK_CONCRETE)
	_add_box("Data terminal screen", Vector3(0.0, 1.35, -24.35), Vector3(1.1, 0.55, 0.12), Color(0.18, 0.34, 0.34))
	_add_label("DATA TERMINAL", Vector3(0.0, 2.5, -23.2), 18, Color(0.55, 0.85, 0.82))
	_add_label("PRESS E TO ACCESS INCIDENT LOG", Vector3(0.0, 2.9, -22.5), 14, Color(0.88, 0.76, 0.48))
	_add_box("Extraction beacon base", Vector3(0.0, 0.15, 17.0), Vector3(2.4, 0.3, 2.4), DARK_CONCRETE)
	_add_box("Extraction beacon mast", Vector3(0.0, 2.2, 17.0), Vector3(0.18, 4.1, 0.18), ACCENT, false)
	_add_box("Extraction beacon crossbar", Vector3(0.0, 4.1, 17.0), Vector3(1.5, 0.12, 0.12), ACCENT, false)
	_add_label("EXTRACTION  /  RENDEZVOUS", Vector3(0.0, 4.8, 16.0), 20, Color(1.0, 0.76, 0.36))
	_create_level_detail_pass()

func _create_level_detail_pass() -> void:
	# Warehouse facade: recessed-looking bays, narrow windows, service conduits,
	# dock bumpers and roof edging add depth without adding dynamic lights.
	for bay_x in [-3.2, 3.2]:
		_add_box("Loading bay inner shadow", Vector3(bay_x, 2.0, -15.48), Vector3(2.5, 3.6, 0.08), DARK_CONCRETE, false)
		_add_box("Loading bay door panel", Vector3(bay_x, 2.05, -15.40), Vector3(2.15, 3.25, 0.06), Color(0.18, 0.22, 0.23), false)
		for rib_y in range(7):
			_add_box("Loading door horizontal rib", Vector3(bay_x, 0.65 + rib_y * 0.43, -15.34), Vector3(2.12, 0.035, 0.035), PALE_METAL, false)
		_add_box("Dock rubber bumper", Vector3(bay_x - 1.2, 0.55, -15.15), Vector3(0.18, 0.75, 0.22), DARK_CONCRETE, false)
		_add_box("Dock rubber bumper", Vector3(bay_x + 1.2, 0.55, -15.15), Vector3(0.18, 0.75, 0.22), DARK_CONCRETE, false)

	for window_x in [-16.0, -13.0, -10.0, 10.0, 13.0, 16.0]:
		_add_box("Warehouse high window", Vector3(window_x, 4.35, -15.91), Vector3(1.65, 0.72, 0.045), Color(0.12, 0.20, 0.22), false)
		_add_box("Warehouse window sill", Vector3(window_x, 3.96, -15.86), Vector3(1.78, 0.08, 0.12), WARM_METAL, false)
		_add_box("Window vertical divider", Vector3(window_x, 4.35, -15.82), Vector3(0.055, 0.72, 0.06), PALE_METAL, false)

	# Exposed utility lines and cable trays make the service building readable.
	for pipe_y in [2.45, 2.72, 2.99]:
		_add_box("Service wall utility pipe", Vector3(10.43, pipe_y, 1.0), Vector3(0.08, 0.08, 6.7), PALE_METAL, false)
	_add_box("Service cable tray", Vector3(14.0, 3.15, -3.12), Vector3(6.5, 0.12, 0.12), DARK_CONCRETE, false)
	_add_box("Service door frame", Vector3(10.34, 1.12, -3.12), Vector3(1.62, 2.34, 0.10), PALE_METAL, false)
	_add_box("Service door handle", Vector3(10.12, 1.15, -3.20), Vector3(0.045, 0.24, 0.045), ACCENT, false)
	_add_label("MAINTENANCE  /  AUTHORIZED STAFF", Vector3(14.0, 2.65, -3.25), 11, Color(0.78, 0.82, 0.77))

	# Container corner castings and vertical ribs; visual-only to keep collision
	# complexity unchanged from the existing playable blockout.
	for z_offset in [-1.42, 1.42]:
		for x_offset in [-2.42, 2.42]:
			_add_box("Container corner casting", Vector3(-12.0 + x_offset, 1.25, -5.0 + z_offset), Vector3(0.16, 2.48, 0.16), PALE_METAL, false)
			_add_box("Container corner casting", Vector3(-12.0 + x_offset, 3.85, -5.0 + z_offset), Vector3(0.16, 2.48, 0.16), PALE_METAL, false)
	for rib_x in range(1, 9):
		var x_pos := -14.25 + rib_x * 0.56
		_add_box("Container corrugation", Vector3(x_pos, 1.25, -3.46), Vector3(0.045, 2.35, 0.055), PALE_METAL, false)
		_add_box("Container corrugation", Vector3(x_pos, 3.85, -3.46), Vector3(0.045, 2.35, 0.055), PALE_METAL, false)
	_add_label("NSTR  /  04", Vector3(-12.0, 2.0, -3.34), 15, Color(0.82, 0.84, 0.76))

	# Yard safety details: bollards, drain grates, wheel stops and painted edges.
	for bollard_x in [-5.0, 5.0]:
		for bollard_z in [-13.0, -10.0]:
			_add_box("Safety bollard base", Vector3(bollard_x, 0.12, bollard_z), Vector3(0.48, 0.24, 0.48), DARK_CONCRETE, false)
			_add_box("Safety bollard", Vector3(bollard_x, 0.65, bollard_z), Vector3(0.18, 1.05, 0.18), ACCENT, false)
			_add_box("Bollard reflective band", Vector3(bollard_x, 0.83, bollard_z), Vector3(0.19, 0.12, 0.19), Color(0.82, 0.78, 0.62), false)
	for drain_z in [-18.0, -7.0, 5.0, 13.0]:
		_add_box("Yard drainage channel", Vector3(8.8, 0.018, drain_z), Vector3(0.42, 0.025, 3.2), DARK_CONCRETE, false)
		for grate_x in range(5):
			_add_box("Drain grate bar", Vector3(8.62 + grate_x * 0.09, 0.035, drain_z), Vector3(0.025, 0.018, 3.0), PALE_METAL, false)
	for stop_z in [-12.0, -9.0]:
		_add_box("Loading wheel stop", Vector3(-7.0, 0.10, stop_z), Vector3(2.0, 0.20, 0.22), WARM_METAL, false)

	# A few static status panels and warning markers provide visual landmarks.
	_add_box("Yard status cabinet", Vector3(-18.8, 1.5, -17.0), Vector3(0.75, 1.8, 0.55), DARK_CONCRETE, false)
	_add_box("Status cabinet face", Vector3(-18.8, 1.65, -16.70), Vector3(0.48, 0.92, 0.035), Color(0.12, 0.20, 0.21), false)
	_add_box("Status green indicator", Vector3(-18.8, 1.95, -16.66), Vector3(0.10, 0.10, 0.035), Color(0.28, 0.58, 0.40), false)
	_add_box("Status amber indicator", Vector3(-18.8, 1.70, -16.66), Vector3(0.10, 0.10, 0.035), ACCENT, false)
	_add_label("GRID  /  AUX POWER", Vector3(-18.8, 2.65, -16.4), 10, Color(0.72, 0.81, 0.77))
	_add_box("Terminal warning stripe left", Vector3(-0.78, 0.18, -23.48), Vector3(0.12, 0.035, 1.05), ACCENT, false)
	_add_box("Terminal warning stripe right", Vector3(0.78, 0.18, -23.48), Vector3(0.12, 0.035, 1.05), ACCENT, false)
	_add_box("Terminal screen bezel", Vector3(0.0, 1.36, -24.43), Vector3(1.22, 0.66, 0.07), PALE_METAL, false)
	_add_box("Terminal screen glass", Vector3(0.0, 1.36, -24.385), Vector3(1.08, 0.52, 0.025), Color(0.10, 0.24, 0.25), false)
	_add_box("Terminal keyboard", Vector3(0.0, 1.04, -24.26), Vector3(0.82, 0.045, 0.28), DARK_CONCRETE, false)

	# Extraction marker gets a clear physical base and reflective identification.
	_add_box("Extraction beacon equipment case", Vector3(1.25, 0.55, 17.0), Vector3(0.8, 1.1, 0.8), DARK_CONCRETE, false)
	_add_box("Extraction case label", Vector3(1.25, 0.58, 16.57), Vector3(0.48, 0.24, 0.035), Color(0.16, 0.28, 0.29), false)
	_add_label("RENDEZVOUS  /  04", Vector3(1.25, 1.35, 16.3), 11, Color(0.86, 0.78, 0.58))

func _add_box(box_name: String, box_position: Vector3, box_size: Vector3, box_color: Color, solid: bool = true) -> void:
	var root: Node3D
	if solid:
		var body := StaticBody3D.new()
		body.name = box_name
		root = body
	else:
		root = Node3D.new()
		root.name = box_name
	root.position = box_position

	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = box_size
	mesh_instance.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = box_color
	material.roughness = 0.9
	mesh_instance.material_override = material
	root.add_child(mesh_instance)

	if solid:
		var collision := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = box_size
		collision.shape = box_shape
		root.add_child(collision)
	add_child(root)

func _add_label(label_text: String, label_position: Vector3, font_size: int, label_color: Color) -> void:
	var label := Label3D.new()
	label.text = label_text
	label.position = label_position
	label.font_size = font_size
	label.modulate = label_color
	label.outline_size = 6
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	add_child(label)

func _create_player() -> void:
	player = PLAYER_SCENE.instantiate() as ShadowFrontPlayer
	player.position = Vector3(0.0, 0.0, 12.0)
	add_child(player)

func _create_mission_manager() -> void:
	mission_manager = ShadowFrontMissionManager.new()
	mission_manager.name = "MissionManager"
	mission_manager.objective_changed.connect(_on_mission_objective_changed)
	mission_manager.mission_completed.connect(_on_mission_completed)
	add_child(mission_manager)
	_create_save_system()
	mission_manager.start_mission([
		"Reach the warehouse loading bay",
		"Recover the data from the terminal",
		"Return to the extraction rendezvous"
	], player.global_position)
	var progress := save_system.load_progress()
	if not progress.is_empty():
		mission_manager.checkpoint_position = progress["checkpoint"]
		player.global_position = progress["checkpoint"]
		mission_manager.current_objective_index = progress["objective_index"]
		saved_mission_complete = progress["mission_complete"]
		if saved_mission_complete:
			mission_manager.current_objective_index = 2
			mission_manager.is_active = false
			mission_manager.is_complete = true
		else:
			mission_manager.is_active = true
			mission_manager.is_complete = false
			mission_manager.objective_changed.emit(mission_manager.current_objective_index, mission_manager.get_current_objective())

func _create_save_system() -> void:
	save_system = ShadowFrontSaveSystem.new()
	save_system.name = "SaveSystem"
	add_child(save_system)
	mission_manager.checkpoint_changed.connect(_on_checkpoint_saved)

func _save_current_progress() -> void:
	if not is_instance_valid(save_system) or not is_instance_valid(mission_manager):
		return
	save_system.save_progress(mission_manager.current_objective_index, mission_manager.checkpoint_position, mission_manager.is_complete)

func _on_checkpoint_saved(position: Vector3) -> void:
	_save_current_progress()

func _create_objective_triggers() -> void:
	_add_objective_trigger("LoadingBayObjectiveTrigger", Vector3(0.0, 1.2, -14.0), 0)
	_add_objective_trigger("ExtractionObjectiveTrigger", Vector3(0.0, 1.2, 17.0), 2)

func _add_objective_trigger(trigger_name: String, trigger_position: Vector3, objective_index: int) -> void:
	var objective_area := Area3D.new()
	objective_area.name = trigger_name
	objective_area.position = trigger_position
	objective_area.collision_layer = 0
	objective_area.collision_mask = 1

	var trigger_shape := CollisionShape3D.new()
	var trigger_box := BoxShape3D.new()
	trigger_box.size = Vector3(5.0, 2.4, 2.4)
	trigger_shape.shape = trigger_box
	objective_area.add_child(trigger_shape)
	objective_area.body_entered.connect(_on_objective_body_entered.bind(objective_index))
	add_child(objective_area)

func _on_objective_body_entered(body: Node3D, objective_index: int) -> void:
	if body != player or mission_manager.is_complete:
		return
	if objective_index != mission_manager.current_objective_index:
		return
	mission_manager.complete_current_objective()
	_save_current_progress()

func _on_mission_objective_changed(index: int, description: String) -> void:
	mission_status_label.text = "%s  |  %s" % [mission_manager.get_objective_counter(), description]
	mission_status_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.42))
	_show_mission_event("OBJECTIVE UPDATED", description, 3.2)

func _on_mission_completed() -> void:
	mission_status_label.text = "MISSION COMPLETE  |  Northstar Terminal secured"
	mission_status_label.add_theme_color_override("font_color", Color(0.55, 0.88, 0.62))
	_save_current_progress()
	_show_mission_event("MISSION COMPLETE", "Northstar Terminal secured", 4.0)
	_show_mission_complete_screen()

func _create_checkpoint_trigger() -> void:
	var checkpoint_area := Area3D.new()
	checkpoint_area.name = "WarehouseCheckpointTrigger"
	checkpoint_area.position = Vector3(0.0, 1.0, -18.0)
	checkpoint_area.collision_layer = 0
	checkpoint_area.collision_mask = 1

	var checkpoint_shape := CollisionShape3D.new()
	var checkpoint_box := BoxShape3D.new()
	checkpoint_box.size = Vector3(4.0, 2.0, 2.0)
	checkpoint_shape.shape = checkpoint_box
	checkpoint_area.add_child(checkpoint_shape)
	checkpoint_area.body_entered.connect(_on_checkpoint_body_entered)
	add_child(checkpoint_area)

func _on_checkpoint_body_entered(body: Node3D) -> void:
	if body != player:
		return
	var safe_position := Vector3(0.0, 0.0, -17.0)
	if mission_manager.checkpoint_position.is_equal_approx(safe_position):
		return
	mission_manager.set_checkpoint(safe_position)
	_save_current_progress()
	mission_status_label.text = "CHECKPOINT SAVED  |  Warehouse entrance"
	mission_status_label.add_theme_color_override("font_color", Color(0.55, 0.82, 0.96))
	_show_mission_event("CHECKPOINT SAVED", "Warehouse entrance", 3.0)

func _create_pause_menu() -> void:
	pause_menu = ShadowFrontPauseMenu.new()
	pause_menu.name = "PauseMenu"
	add_child(pause_menu)
	pause_menu.configure(player, save_system, mission_manager, world_environment_node)
	pause_menu.restart_requested.connect(_restart_mission)

func _restart_mission() -> void:
	if is_instance_valid(save_system):
		var clear_error := save_system.clear_progress()
		if clear_error != OK:
			push_warning("Could not clear the previous mission save: %s" % error_string(clear_error))
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().reload_current_scene()

func _create_companion() -> void:
	companion = ShadowFrontCompanion.new()
	companion.name = "SquadCompanion"
	companion.follow_target = player
	companion.position = player.global_position + Vector3(2.0, 0.0, 1.0)
	companion.set_process(false)
	add_child(companion)

func _on_companion_interaction() -> void:
	if not is_instance_valid(companion) or not is_instance_valid(player):
		return
	if companion.global_position.distance_to(player.global_position) > 3.5:
		return
	var radio_line := companion.get_radio_line(mission_manager.current_objective_index)
	companion.play_radio_acknowledgement()
	mission_status_label.text = "SQUAD LINK  |  " + radio_line
	mission_status_label.add_theme_color_override("font_color", Color(0.60, 0.83, 0.95))
	if is_instance_valid(squad_dialogue_label):
		squad_dialogue_label.text = "ELIAS ROOK  /  " + radio_line
		squad_dialogue_label.visible = true
		squad_dialogue_time_remaining = 4.8

func _open_terminal_intel() -> void:
	if has_meta("intel_overlay_layer") or mission_manager.current_objective_index != 1:
		return
	var intel_layer := CanvasLayer.new()
	intel_layer.name = "TerminalIntel"
	intel_layer.layer = 12
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	intel_layer.add_child(root)
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.008, 0.018, 0.024, 0.94)
	root.add_child(backdrop)
	var panel := ColorRect.new()
	panel.position = Vector2(125.0, 105.0)
	panel.size = Vector2(1030.0, 510.0)
	panel.color = Color(0.045, 0.075, 0.078, 0.99)
	root.add_child(panel)
	var heading := Label.new()
	heading.position = Vector2(48.0, 36.0)
	heading.size = Vector2(930.0, 32.0)
	heading.text = "NORTHSTAR TERMINAL  /  RECOVERED INCIDENT LOG 04"
	heading.add_theme_color_override("font_color", Color(0.67, 0.84, 0.79))
	heading.add_theme_font_size_override("font_size", 17)
	panel.add_child(heading)
	var title := Label.new()
	title.position = Vector2(48.0, 88.0)
	title.size = Vector2(930.0, 58.0)
	title.text = "THE TRANSMISSION DOESN'T MATCH"
	title.add_theme_color_override("font_color", Color(0.94, 0.91, 0.82))
	title.add_theme_font_size_override("font_size", 30)
	panel.add_child(title)
	var rule := ColorRect.new()
	rule.position = Vector2(48.0, 160.0)
	rule.size = Vector2(930.0, 2.0)
	rule.color = ACCENT
	panel.add_child(rule)
	var evidence := Label.new()
	evidence.position = Vector2(48.0, 190.0)
	evidence.size = Vector2(930.0, 210.0)
	evidence.text = "LOCAL SYSTEM RECORD  /  02:14\n\nThe terminal log confirms that the emergency broadcast was authenticated after the Northstar relief convoy had already checked in safely. The public alert described the convoy as missing.\n\nA second entry references an external relay tagged VEYRA-7. The sender identity has been removed from this copy.\n\nElias: \"That timestamp is wrong. Someone wanted the alert to look like it came first.\""
	evidence.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	evidence.add_theme_color_override("font_color", Color(0.82, 0.88, 0.86))
	evidence.add_theme_font_size_override("font_size", 18)
	panel.add_child(evidence)
	var prompt := Label.new()
	prompt.position = Vector2(48.0, 450.0)
	prompt.size = Vector2(930.0, 30.0)
	prompt.text = "DATA COPIED  /  PRESS ENTER TO CLOSE AND CONTINUE"
	prompt.add_theme_color_override("font_color", Color(1.0, 0.78, 0.43))
	prompt.add_theme_font_size_override("font_size", 17)
	panel.add_child(prompt)
	add_child(intel_layer)
	set_meta("intel_overlay_layer", intel_layer)
	pause_menu.set_pause_allowed(false)
	player.set_physics_process(false)
	companion.set_process(false)
	player.mouse_captured = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _close_terminal_intel() -> void:
	if not has_meta("intel_overlay_layer"):
		return
	var intel_layer := get_meta("intel_overlay_layer") as CanvasLayer
	if is_instance_valid(intel_layer):
		intel_layer.queue_free()
	remove_meta("intel_overlay_layer")
	pause_menu.set_pause_allowed(true)
	player.set_physics_process(true)
	companion.set_process(true)
	player.mouse_captured = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mission_manager.complete_current_objective()
	_save_current_progress()
	mission_status_label.text = "INTEL RECOVERED  |  Return to the extraction rendezvous"
	mission_status_label.add_theme_color_override("font_color", Color(0.55, 0.85, 0.82))

func _show_mission_complete_screen() -> void:
	if has_meta("mission_complete_layer"):
		return
	var complete_layer := CanvasLayer.new()
	complete_layer.name = "MissionDebrief"
	complete_layer.layer = 14
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	complete_layer.add_child(root)
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.008, 0.015, 0.022, 0.92)
	root.add_child(backdrop)
	var panel := ColorRect.new()
	panel.position = Vector2(150.0, 130.0)
	panel.size = Vector2(980.0, 460.0)
	panel.color = Color(0.045, 0.065, 0.075, 0.99)
	root.add_child(panel)
	var kicker := Label.new()
	kicker.position = Vector2(52.0, 45.0)
	kicker.size = Vector2(870.0, 28.0)
	kicker.text = "PROJECT: SHADOW FRONT  /  FIELD REPORT"
	kicker.add_theme_color_override("font_color", Color(0.67, 0.79, 0.81))
	kicker.add_theme_font_size_override("font_size", 16)
	panel.add_child(kicker)
	var title := Label.new()
	title.position = Vector2(52.0, 105.0)
	title.size = Vector2(870.0, 62.0)
	title.text = "MISSION COMPLETE"
	title.add_theme_color_override("font_color", Color(0.90, 0.88, 0.78))
	title.add_theme_font_size_override("font_size", 36)
	panel.add_child(title)
	var summary := Label.new()
	summary.position = Vector2(52.0, 190.0)
	summary.size = Vector2(870.0, 140.0)
	summary.text = "NORTHSTAR: FIRST CONTACT\n\nThe terminal data is secured. The squad reached the rendezvous, but the recovered timestamp raises a new question: who sent the false alert, and why?"
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_color_override("font_color", Color(0.82, 0.87, 0.87))
	summary.add_theme_font_size_override("font_size", 19)
	panel.add_child(summary)
	var status := Label.new()
	status.position = Vector2(52.0, 370.0)
	status.size = Vector2(870.0, 30.0)
	status.text = "OBJECTIVES COMPLETE  /  DATA SECURED  /  SQUAD ACCOUNTED FOR"
	status.add_theme_color_override("font_color", Color(0.58, 0.86, 0.66))
	status.add_theme_font_size_override("font_size", 16)
	panel.add_child(status)
	add_child(complete_layer)
	set_meta("mission_complete_layer", complete_layer)
	pause_menu.set_pause_allowed(false)
	player.set_physics_process(false)
	companion.set_process(false)
	player.mouse_captured = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _create_deployment_briefing() -> void:
	var briefing_layer := CanvasLayer.new()
	briefing_layer.name = "DeploymentBriefing"
	briefing_layer.layer = 10

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	briefing_layer.add_child(root)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.015, 0.025, 0.035, 0.94)
	root.add_child(backdrop)

	var card := ColorRect.new()
	card.position = Vector2(110.0, 105.0)
	card.size = Vector2(1060.0, 510.0)
	card.color = Color(0.055, 0.075, 0.085, 0.98)
	root.add_child(card)

	var eyebrow := Label.new()
	eyebrow.position = Vector2(52.0, 42.0)
	eyebrow.size = Vector2(950.0, 30.0)
	eyebrow.text = "PROJECT: SHADOW FRONT     /     SINGLE-PLAYER CAMPAIGN"
	eyebrow.add_theme_color_override("font_color", Color(0.65, 0.76, 0.78))
	eyebrow.add_theme_font_size_override("font_size", 16)
	card.add_child(eyebrow)

	var title := Label.new()
	title.position = Vector2(52.0, 90.0)
	title.size = Vector2(950.0, 62.0)
	title.text = "NORTHSTAR: FIRST CONTACT"
	title.add_theme_color_override("font_color", Color(0.94, 0.91, 0.82))
	title.add_theme_font_size_override("font_size", 34)
	card.add_child(title)

	var divider := ColorRect.new()
	divider.position = Vector2(52.0, 166.0)
	divider.size = Vector2(950.0, 2.0)
	divider.color = Color(0.66, 0.48, 0.27)
	card.add_child(divider)

	var briefing := Label.new()
	briefing.position = Vector2(52.0, 198.0)
	briefing.size = Vector2(950.0, 112.0)
	briefing.text = "Northstar Terminal has gone silent. The last transmission ended before the night shift could confirm what happened. Enter the warehouse with your squad partner, recover the data from the central console, then return to the marked rendezvous.\n\nYour partner will keep pace and can be checked in with using E when nearby."
	briefing.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	briefing.add_theme_color_override("font_color", Color(0.80, 0.85, 0.86))
	briefing.add_theme_font_size_override("font_size", 18)
	card.add_child(briefing)

	var objective_heading := Label.new()
	objective_heading.position = Vector2(52.0, 335.0)
	objective_heading.size = Vector2(950.0, 28.0)
	objective_heading.text = "MISSION OBJECTIVES"
	objective_heading.add_theme_color_override("font_color", Color(0.91, 0.70, 0.40))
	objective_heading.add_theme_font_size_override("font_size", 16)
	card.add_child(objective_heading)

	var objectives := Label.new()
	objectives.position = Vector2(52.0, 372.0)
	objectives.size = Vector2(950.0, 60.0)
	objectives.text = "01   Reach the warehouse loading bay\n02   Recover the data from the terminal\n03   Return to the extraction rendezvous"
	objectives.add_theme_color_override("font_color", Color(0.90, 0.92, 0.91))
	objectives.add_theme_font_size_override("font_size", 18)
	card.add_child(objectives)

	var deploy_prompt := Label.new()
	deploy_prompt.position = Vector2(52.0, 455.0)
	deploy_prompt.size = Vector2(950.0, 30.0)
	deploy_prompt.text = "PRESS ENTER TO DEPLOY"
	deploy_prompt.add_theme_color_override("font_color", Color(1.0, 0.78, 0.43))
	deploy_prompt.add_theme_font_size_override("font_size", 18)
	card.add_child(deploy_prompt)

	add_child(briefing_layer)
	player.set_physics_process(false)
	companion.set_process(false)
	player.mouse_captured = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	set_meta("deployment_briefing_layer", briefing_layer)
	pause_menu.set_pause_allowed(false)

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if has_meta("deployment_briefing_layer"):
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			var briefing_layer := get_meta("deployment_briefing_layer") as CanvasLayer
			if is_instance_valid(briefing_layer):
				briefing_layer.queue_free()
			remove_meta("deployment_briefing_layer")
			if saved_mission_complete:
				_show_mission_complete_screen()
			else:
				pause_menu.set_pause_allowed(true)
				player.set_physics_process(true)
				companion.set_process(true)
				player.mouse_captured = true
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()
		return
	if has_meta("intel_overlay_layer"):
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_close_terminal_intel()
			get_viewport().set_input_as_handled()
		return
	if has_meta("mission_complete_layer"):
		return
	if event.keycode == KEY_E:
		if mission_manager.current_objective_index == 1 and player.global_position.distance_to(Vector3(0.0, 0.0, -24.0)) <= 3.5:
			_open_terminal_intel()
		else:
			_on_companion_interaction()

func _process(delta: float) -> void:
	_update_interaction_feedback()
	navigation_refresh_time -= delta
	if navigation_refresh_time <= 0.0:
		navigation_refresh_time = 0.15
		_update_navigation_feedback()
	if mission_event_time_remaining > 0.0:
		mission_event_time_remaining = maxf(0.0, mission_event_time_remaining - delta)
		if mission_event_time_remaining <= 0.0 and is_instance_valid(mission_event_label):
			mission_event_label.visible = false
	if squad_dialogue_time_remaining > 0.0:
		squad_dialogue_time_remaining = maxf(0.0, squad_dialogue_time_remaining - delta)
		if squad_dialogue_time_remaining <= 0.0 and is_instance_valid(squad_dialogue_label):
			squad_dialogue_label.visible = false

func _update_navigation_feedback() -> void:
	if not is_instance_valid(navigation_label) or not is_instance_valid(player) or not is_instance_valid(mission_manager):
		return
	if mission_manager.is_complete or has_meta("deployment_briefing_layer") or has_meta("mission_complete_layer"):
		navigation_label.visible = false
		return
	var targets: Array[Vector3] = [
		Vector3(0.0, 0.0, -14.0),
		Vector3(0.0, 0.0, -24.0),
		Vector3(0.0, 0.0, 17.0)
	]
	var index := clampi(mission_manager.current_objective_index, 0, targets.size() - 1)
	var offset := targets[index] - player.global_position
	var distance := offset.length()
	var local_direction := player.global_transform.basis.inverse() * offset.normalized()
	var direction_text := "AHEAD"
	if local_direction.z > 0.45:
		direction_text = "BEHIND"
	elif local_direction.x < -0.35:
		direction_text = "LEFT"
	elif local_direction.x > 0.35:
		direction_text = "RIGHT"
	navigation_label.text = "OBJECTIVE  %dm   /   %s" % [roundi(distance), direction_text]
	navigation_label.visible = true

func _show_mission_event(heading: String, detail: String, duration: float) -> void:
	if not is_instance_valid(mission_event_label):
		return
	mission_event_label.text = heading + "  /  " + detail
	mission_event_label.visible = true
	mission_event_time_remaining = duration

func _update_interaction_feedback() -> void:
	if not is_instance_valid(interaction_prompt_label) or not is_instance_valid(player):
		return
	if has_meta("deployment_briefing_layer") or has_meta("intel_overlay_layer") or has_meta("mission_complete_layer"):
		interaction_prompt_label.visible = false
		return
	var prompt_text := ""
	if mission_manager.current_objective_index == 1 and player.global_position.distance_to(Vector3(0.0, 0.0, -24.0)) <= 3.5:
		prompt_text = "E   ACCESS INCIDENT LOG"
	elif is_instance_valid(companion) and companion.global_position.distance_to(player.global_position) <= 3.5:
		prompt_text = "E   CHECK IN WITH ELIAS"
	interaction_prompt_label.text = prompt_text
	interaction_prompt_label.visible = not prompt_text.is_empty()

func _physics_process(_delta: float) -> void:
	if is_instance_valid(player) and player.global_position.y < -5.0:
		player.global_position = mission_manager.checkpoint_position
		player.velocity = Vector3.ZERO

func _create_hud() -> void:
	var layer := CanvasLayer.new()
	var panel := ColorRect.new()
	panel.position = Vector2(18.0, 18.0)
	panel.size = Vector2(600.0, 132.0)
	panel.color = Color(0.025, 0.035, 0.045, 0.78)
	layer.add_child(panel)

	var label := Label.new()
	label.position = Vector2(14.0, 12.0)
	label.size = Vector2(570.0, 80.0)
	label.text = "PROJECT: SHADOW FRONT  |  NORTHSTAR TERMINAL\nWASD Move   SHIFT Sprint   SPACE Jump\nCTRL / C Crouch   E Squad Check-in\nMouse Look   ESC Release Mouse   P Pause"
	label.add_theme_color_override("font_color", Color(0.91, 0.94, 0.96))
	label.add_theme_font_size_override("font_size", 16)
	panel.add_child(label)

	navigation_label = Label.new()
	navigation_label.name = "ObjectiveNavigation"
	navigation_label.anchor_left = 0.68
	navigation_label.anchor_right = 0.98
	navigation_label.anchor_top = 0.035
	navigation_label.anchor_bottom = 0.095
	navigation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	navigation_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	navigation_label.add_theme_font_size_override("font_size", 17)
	navigation_label.add_theme_color_override("font_color", Color(0.88, 0.91, 0.86))
	navigation_label.add_theme_color_override("font_outline_color", Color(0.015, 0.025, 0.03, 0.98))
	navigation_label.add_theme_constant_override("outline_size", 5)
	layer.add_child(navigation_label)

	mission_status_label = Label.new()
	mission_status_label.position = Vector2(14.0, 92.0)
	mission_status_label.size = Vector2(570.0, 26.0)
	mission_status_label.text = "OBJECTIVE: Reach the warehouse loading bay"
	mission_status_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.42))
	mission_status_label.add_theme_font_size_override("font_size", 16)
	panel.add_child(mission_status_label)

	mission_event_label = Label.new()
	mission_event_label.name = "MissionEventFeedback"
	mission_event_label.anchor_left = 0.18
	mission_event_label.anchor_right = 0.82
	mission_event_label.anchor_top = 0.105
	mission_event_label.anchor_bottom = 0.18
	mission_event_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mission_event_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mission_event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mission_event_label.add_theme_font_size_override("font_size", 22)
	mission_event_label.add_theme_color_override("font_color", Color(0.91, 0.88, 0.76))
	mission_event_label.add_theme_color_override("font_outline_color", Color(0.015, 0.025, 0.03, 0.98))
	mission_event_label.add_theme_constant_override("outline_size", 5)
	mission_event_label.visible = false
	layer.add_child(mission_event_label)

	interaction_prompt_label = Label.new()
	interaction_prompt_label.name = "InteractionPrompt"
	interaction_prompt_label.anchor_left = 0.20
	interaction_prompt_label.anchor_right = 0.80
	interaction_prompt_label.anchor_top = 0.885
	interaction_prompt_label.anchor_bottom = 0.93
	interaction_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interaction_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	interaction_prompt_label.add_theme_font_size_override("font_size", 19)
	interaction_prompt_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.52))
	interaction_prompt_label.add_theme_color_override("font_outline_color", Color(0.015, 0.025, 0.03, 0.95))
	interaction_prompt_label.add_theme_constant_override("outline_size", 5)
	interaction_prompt_label.visible = false
	layer.add_child(interaction_prompt_label)

	squad_dialogue_label = Label.new()
	squad_dialogue_label.name = "SquadDialogueSubtitle"
	squad_dialogue_label.anchor_left = 0.12
	squad_dialogue_label.anchor_right = 0.88
	squad_dialogue_label.anchor_top = 0.82
	squad_dialogue_label.anchor_bottom = 0.875
	squad_dialogue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	squad_dialogue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	squad_dialogue_label.add_theme_font_size_override("font_size", 20)
	squad_dialogue_label.add_theme_color_override("font_color", Color(0.90, 0.94, 0.93))
	squad_dialogue_label.add_theme_color_override("font_outline_color", Color(0.015, 0.025, 0.03, 0.98))
	squad_dialogue_label.add_theme_constant_override("outline_size", 5)
	squad_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	squad_dialogue_label.visible = false
	layer.add_child(squad_dialogue_label)

	add_child(layer)
