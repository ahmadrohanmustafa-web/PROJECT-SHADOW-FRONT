extends Node3D

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const WALL := Color(0.16, 0.20, 0.22)
const BUILDING := Color(0.34, 0.37, 0.35)
const ACCENT := Color(0.72, 0.48, 0.22)
const SAVE_PATH := "user://shadow_front_save.cfg"
const SAVE_SECTION := "the_quiet_district"

var player: ShadowFrontPlayer
var companion: ShadowFrontCompanion
var objective_label: Label
var prompt_label: Label
var briefing_layer: CanvasLayer
var debrief_layer: CanvasLayer
var objective_index: int = 0
var interaction_cooldown: bool = false
var pause_layer: CanvasLayer
var is_paused: bool = false
var saved_mission_complete: bool = false

const OBJECTIVES: Array[String] = [
	"Reach the Larkspur clinic entrance",
	"Check in with Nadia at the clinic",
	"Recover the dispatch record from the municipal terminal",
	"Return to the transit plaza rendezvous"
]

func _ready() -> void:
	_create_environment()
	_create_world()
	_create_player()
	_create_companion()
	_create_hud()
	_load_progress()
	_show_briefing()

func _create_environment() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.055, 0.075, 0.085)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.55, 0.62, 0.65)
	environment.ambient_light_energy = 0.8
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = environment
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42.0, -25.0, 0.0)
	sun.light_energy = 0.45
	sun.shadow_enabled = false
	add_child(sun)

func _create_world() -> void:
	_add_box("Larkspur street", Vector3(0, -0.15, 0), Vector3(46, 0.3, 52), Color(0.18, 0.20, 0.20), false)
	_add_box("Clinic exterior", Vector3(-10, 2.4, -12), Vector3(12, 4.8, 9), BUILDING)
	_add_box("Clinic roof", Vector3(-10, 4.95, -12), Vector3(12.5, 0.3, 9.5), WALL)
	_add_box("Clinic entrance", Vector3(-10, 1.2, -7.35), Vector3(2.2, 2.4, 0.18), Color(0.12, 0.22, 0.23))
	_add_label("LARKSPUR COMMUNITY CLINIC", Vector3(-10, 3.6, -6.9), 18, Color(0.78, 0.85, 0.82))
	_add_box("Market block", Vector3(13, 2.6, -14), Vector3(10, 5.2, 11), Color(0.30, 0.27, 0.23))
	_add_box("Records office", Vector3(11, 2.2, 11), Vector3(12, 4.4, 9), Color(0.26, 0.32, 0.33))
	_add_box("Records roof", Vector3(11, 4.55, 11), Vector3(12.5, 0.3, 9.5), WALL)
	_add_box("Transit shelter", Vector3(0, 1.5, 20), Vector3(12, 0.25, 4), WALL)
	_add_box("Shelter left post", Vector3(-5.7, 1.0, 20), Vector3(0.2, 2, 0.2), ACCENT)
	_add_box("Shelter right post", Vector3(5.7, 1.0, 20), Vector3(0.2, 2, 0.2), ACCENT)
	_add_label("TRANSIT PLAZA  /  RENDEZVOUS", Vector3(0, 3.2, 17.5), 20, Color(0.92, 0.76, 0.48))
	_add_box("Clinic approach barrier", Vector3(-2, 0.55, -5), Vector3(3.5, 1.1, 0.35), ACCENT)
	_add_box("Market kiosk", Vector3(16, 1.0, -3), Vector3(3.5, 2, 2.5), Color(0.43, 0.34, 0.25))
	_add_label("MUNICIPAL RECORDS", Vector3(11, 3.4, 5.9), 18, Color(0.75, 0.85, 0.84))
	_add_box("Records terminal", Vector3(11, 0.75, 9.0), Vector3(1.4, 1.5, 0.8), WALL)
	_add_box("Records screen", Vector3(11, 1.65, 8.65), Vector3(1.0, 0.55, 0.1), Color(0.20, 0.43, 0.42), false)
	_add_label("PRESS E  /  DISPATCH ARCHIVE", Vector3(11, 2.7, 8.1), 13, Color(0.66, 0.88, 0.82))
	_add_label("SAFE SHELTER", Vector3(0, 2.4, 22.5), 16, Color(0.73, 0.86, 0.82))
	_add_box("North boundary", Vector3(0, 2, -26), Vector3(46, 4, 0.5), WALL)
	_add_box("West boundary", Vector3(-23, 2, 0), Vector3(0.5, 4, 52), WALL)
	_add_box("East boundary", Vector3(23, 2, 0), Vector3(0.5, 4, 52), WALL)

func _add_box(label: String, at: Vector3, dimensions: Vector3, tint: Color, solid: bool = true) -> void:
	var root: Node3D
	if solid:
		var body := StaticBody3D.new()
		body.name = label
		root = body
	else:
		root = Node3D.new()
		root.name = label
	root.position = at
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.95
	mesh_instance.material_override = material
	root.add_child(mesh_instance)
	if solid:
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = dimensions
		collision.shape = shape
		root.add_child(collision)
	add_child(root)

func _add_label(value: String, at: Vector3, size: int, tint: Color) -> void:
	var label := Label3D.new()
	label.text = value
	label.position = at
	label.font_size = size
	label.modulate = tint
	label.outline_size = 6
	add_child(label)

func _create_player() -> void:
	player = PLAYER_SCENE.instantiate() as ShadowFrontPlayer
	player.position = Vector3(0, 0, 15)
	add_child(player)

func _create_companion() -> void:
	companion = ShadowFrontCompanion.new()
	companion.name = "SquadCompanion"
	companion.follow_target = player
	companion.position = Vector3(2, 0, 17)
	add_child(companion)

func _create_hud() -> void:
	var layer := CanvasLayer.new()
	var panel := ColorRect.new()
	panel.position = Vector2(18, 18)
	panel.size = Vector2(650, 116)
	panel.color = Color(0.02, 0.035, 0.045, 0.82)
	layer.add_child(panel)
	var heading := Label.new()
	heading.position = Vector2(14, 10)
	heading.size = Vector2(620, 28)
	heading.text = "PROJECT: SHADOW FRONT  /  02 — THE QUIET DISTRICT"
	heading.add_theme_font_size_override("font_size", 16)
	panel.add_child(heading)
	objective_label = Label.new()
	objective_label.position = Vector2(14, 48)
	objective_label.size = Vector2(620, 28)
	objective_label.text = "OBJECTIVE 1 / 4  |  " + OBJECTIVES[0]
	objective_label.add_theme_color_override("font_color", Color(1, 0.79, 0.45))
	objective_label.add_theme_font_size_override("font_size", 16)
	panel.add_child(objective_label)
	prompt_label = Label.new()
	prompt_label.position = Vector2(14, 82)
	prompt_label.size = Vector2(620, 24)
	prompt_label.text = "WASD Move  •  Mouse Look  •  E Interact  •  P Pause"
	prompt_label.add_theme_font_size_override("font_size", 14)
	panel.add_child(prompt_label)
	add_child(layer)

func _show_briefing() -> void:
	briefing_layer = _make_overlay("MISSION BRIEFING", "THE QUIET DISTRICT", "Larkspur Ward has gone dark. Two relief coordinators checked in from the community clinic and then stopped responding. Nadia is already nearby. Confirm the coordinators are safe, recover the municipal dispatch record, and meet the team at the transit plaza.\n\nThis is a search and evidence-recovery mission. No hostile engagement is required.")
	player.set_physics_process(false)
	companion.set_process(false)
	player.mouse_captured = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _make_overlay(kicker: String, title_text: String, body_text: String) -> CanvasLayer:
	var layer := CanvasLayer.new()
	layer.layer = 12
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.008, 0.018, 0.024, 0.94)
	root.add_child(shade)
	var panel := ColorRect.new()
	panel.position = Vector2(130, 120)
	panel.size = Vector2(1020, 480)
	panel.color = Color(0.045, 0.075, 0.078, 0.99)
	root.add_child(panel)
	var top := Label.new()
	top.position = Vector2(48, 35)
	top.size = Vector2(920, 28)
	top.text = "PROJECT: SHADOW FRONT  /  " + kicker
	top.add_theme_color_override("font_color", Color(0.67, 0.84, 0.79))
	panel.add_child(top)
	var heading := Label.new()
	heading.position = Vector2(48, 85)
	heading.size = Vector2(920, 60)
	heading.text = title_text
	heading.add_theme_font_size_override("font_size", 32)
	heading.add_theme_color_override("font_color", Color(0.94, 0.91, 0.82))
	panel.add_child(heading)
	var body := Label.new()
	body.position = Vector2(48, 170)
	body.size = Vector2(920, 210)
	body.text = body_text
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 19)
	body.add_theme_color_override("font_color", Color(0.82, 0.88, 0.86))
	panel.add_child(body)
	var prompt := Label.new()
	prompt.position = Vector2(48, 420)
	prompt.size = Vector2(920, 30)
	prompt.text = "PRESS ENTER TO CONTINUE"
	prompt.add_theme_color_override("font_color", Color(1.0, 0.78, 0.43))
	panel.add_child(prompt)
	add_child(layer)
	return layer

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if is_instance_valid(briefing_layer):
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			briefing_layer.queue_free()
			briefing_layer = null
			if saved_mission_complete:
				_show_debrief()
			else:
				player.set_physics_process(true)
				companion.set_process(true)
				player.mouse_captured = true
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()
		return
	if is_instance_valid(debrief_layer):
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		get_viewport().set_input_as_handled()
		return
	if event.keycode == KEY_P:
		_toggle_pause()
		get_viewport().set_input_as_handled()
		return
	if event.keycode == KEY_E:
		_handle_interaction()

func _toggle_pause() -> void:
	if is_instance_valid(briefing_layer) or is_instance_valid(debrief_layer):
		return
	if is_paused:
		_resume_game()
		return
	is_paused = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pause_layer = CanvasLayer.new()
	pause_layer.name = "MissionPause"
	pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_layer.layer = 30
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_layer.add_child(root)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.008, 0.015, 0.022, 0.92)
	root.add_child(shade)
	var panel := PanelContainer.new()
	panel.position = Vector2(390, 190)
	panel.size = Vector2(500, 340)
	root.add_child(panel)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18)
	panel.add_child(layout)
	var heading := Label.new()
	heading.text = "FIELD MENU  /  THE QUIET DISTRICT"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 22)
	layout.add_child(heading)
	var resume := Button.new()
	resume.text = "RESUME"
	resume.custom_minimum_size.y = 52
	resume.pressed.connect(_resume_game)
	layout.add_child(resume)
	var menu := Button.new()
	menu.text = "RETURN TO CAMPAIGN MENU"
	menu.custom_minimum_size.y = 48
	menu.pressed.connect(_return_to_menu)
	layout.add_child(menu)
	add_child(pause_layer)

func _resume_game() -> void:
	if not is_paused:
		return
	is_paused = false
	get_tree().paused = false
	if is_instance_valid(pause_layer):
		pause_layer.queue_free()
	pause_layer = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _return_to_menu() -> void:
	get_tree().paused = false
	is_paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _process(_delta: float) -> void:
	if is_instance_valid(briefing_layer) or is_instance_valid(debrief_layer):
		return
	if objective_index == 0 and player.global_position.distance_to(Vector3(-10, 0, -6)) < 5.0:
		_complete_objective()
	elif objective_index == 3 and player.global_position.distance_to(Vector3(0, 0, 20)) < 5.0:
		_complete_objective()

func _handle_interaction() -> void:
	if objective_index == 1 and player.global_position.distance_to(Vector3(-10, 0, -6)) < 5.5:
		objective_label.text = "NADIA  |  The coordinators are safe inside. Their dispatch receipt is missing from the municipal archive."
		prompt_label.text = "NADIA VENN  /  CHECK-IN CONFIRMED"
		_complete_objective()
	elif objective_index == 2 and player.global_position.distance_to(Vector3(11, 0, 9)) < 4.5:
		objective_label.text = "ARCHIVE RECOVERED  |  The dispatch receipt was amended after the clinic check-in."
		prompt_label.text = "EVIDENCE COPIED  /  VEYRA-7 REFERENCE FOUND"
		_complete_objective()
	elif player.global_position.distance_to(companion.global_position) < 4.0:
		prompt_label.text = "ELIAS  |  " + companion.get_radio_line(objective_index)

func _complete_objective() -> void:
	if objective_index >= OBJECTIVES.size():
		return
	objective_index += 1
	_save_progress()
	if objective_index >= OBJECTIVES.size():
		saved_mission_complete = true
		_save_progress()
		objective_label.text = "ALL OBJECTIVES COMPLETE  |  Larkspur team accounted for"
		_show_debrief()
	else:
		objective_label.text = "OBJECTIVE %d / 4  |  %s" % [objective_index + 1, OBJECTIVES[objective_index]]

func _load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	if config.get_value(SAVE_SECTION, "mission_id", "") != "the_quiet_district":
		return
	objective_index = clampi(int(config.get_value(SAVE_SECTION, "objective_index", 0)), 0, OBJECTIVES.size())
	saved_mission_complete = bool(config.get_value(SAVE_SECTION, "mission_complete", false))
	if saved_mission_complete:
		objective_index = OBJECTIVES.size()
		objective_label.text = "MISSION COMPLETE  |  Larkspur team accounted for"
	elif objective_index < OBJECTIVES.size():
		objective_label.text = "OBJECTIVE %d / 4  |  %s" % [objective_index + 1, OBJECTIVES[objective_index]]

func _save_progress() -> void:
	var config := ConfigFile.new()
	var load_error := config.load(SAVE_PATH)
	if load_error != OK and load_error != ERR_FILE_NOT_FOUND:
		push_warning("Could not read campaign save: %s" % error_string(load_error))
		return
	config.set_value(SAVE_SECTION, "mission_id", "the_quiet_district")
	config.set_value(SAVE_SECTION, "objective_index", clampi(objective_index, 0, OBJECTIVES.size()))
	config.set_value(SAVE_SECTION, "mission_complete", saved_mission_complete)
	var save_error := config.save(SAVE_PATH)
	if save_error != OK:
		push_warning("Could not save The Quiet District progress: %s" % error_string(save_error))

func _show_debrief() -> void:
	saved_mission_complete = true
	_save_progress()
	debrief_layer = _make_overlay("FIELD REPORT", "THE RECORD WAS CHANGED", "The two relief coordinators are safe. The municipal archive shows that the dispatch receipt was amended after their clinic check-in. The change carries the same VEYRA-7 reference recovered at Northstar.\n\nNadia: \"Someone edited the record after the fact. They wanted the timeline to tell a different story.\"\n\nMISSION COMPLETE  /  TEAM ACCOUNTED FOR  /  EVIDENCE SECURED")
	player.set_physics_process(false)
	companion.set_process(false)
	player.mouse_captured = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
