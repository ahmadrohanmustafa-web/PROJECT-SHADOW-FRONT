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

func _ready() -> void:
	_create_environment()
	_create_level()
	_create_player()
	_create_hud()
	_create_mission_manager()
	_create_objective_triggers()
	_create_checkpoint_trigger()
	_create_companion()
	_create_deployment_briefing()

func _create_environment() -> void:
	var world_environment := WorldEnvironment.new()
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

func _on_mission_completed() -> void:
	mission_status_label.text = "MISSION COMPLETE  |  Northstar Terminal secured"
	mission_status_label.add_theme_color_override("font_color", Color(0.55, 0.88, 0.62))
	_save_current_progress()
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

func _create_companion() -> void:
	companion = ShadowFrontCompanion.new()
	companion.name = "SquadCompanion"
	companion.follow_target = player
	companion.position = Vector3(2.0, 0.0, 13.0)
	companion.set_process(false)
	add_child(companion)

func _on_companion_interaction() -> void:
	if not is_instance_valid(companion) or not is_instance_valid(player):
		return
	if companion.global_position.distance_to(player.global_position) > 3.5:
		return
	mission_status_label.text = "SQUAD LINK  |  " + companion.get_radio_line(mission_manager.current_objective_index)
	mission_status_label.add_theme_color_override("font_color", Color(0.60, 0.83, 0.95))

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
	evidence.text = "LOCAL SYSTEM RECORD  /  02:14\\n\\nThe terminal log confirms that the emergency broadcast was authenticated after the Northstar relief convoy had already checked in safely. The public alert described the convoy as missing.\\n\\nA second entry references an external relay tagged VEYRA-7. The sender identity has been removed from this copy.\\n\\nElias: \\"That timestamp is wrong. Someone wanted the alert to look like it came first.\\""
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
	summary.text = "NORTHSTAR: FIRST CONTACT\\n\\nThe terminal data is secured. The squad reached the rendezvous, but the recovered timestamp raises a new question: who sent the false alert, and why?"
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

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if has_meta("deployment_briefing_layer"):
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			var briefing_layer := get_meta("deployment_briefing_layer") as CanvasLayer
			if is_instance_valid(briefing_layer):
				briefing_layer.queue_free()
			remove_meta("deployment_briefing_layer")
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
	label.text = "PROJECT: SHADOW FRONT  |  NORTHSTAR TERMINAL\nWASD Move   SHIFT Sprint   SPACE Jump\nCTRL / C Crouch   E Squad Check-in\nMouse Look   ESC Release Mouse"
	label.add_theme_color_override("font_color", Color(0.91, 0.94, 0.96))
	label.add_theme_font_size_override("font_size", 16)
	panel.add_child(label)

	mission_status_label = Label.new()
	mission_status_label.position = Vector2(14.0, 92.0)
	mission_status_label.size = Vector2(570.0, 26.0)
	mission_status_label.text = "OBJECTIVE: Reach the warehouse loading bay"
	mission_status_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.42))
	mission_status_label.add_theme_font_size_override("font_size", 16)
	panel.add_child(mission_status_label)
	add_child(layer)
