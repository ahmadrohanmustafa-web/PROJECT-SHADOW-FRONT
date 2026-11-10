extends Node3D

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const SAVE_PATH := "user://shadow_front_save.cfg"
const SAVE_SECTION := "paper_trails"
const WALL := Color(0.16, 0.20, 0.22)
const ACCENT := Color(0.72, 0.48, 0.22)
const OBJECTIVES: Array[String] = [
	"Reach the Larkspur records annex",
	"Speak with archivist Imani",
	"Compare the amended dispatch ledger",
	"Collect the witness statement",
	"Return to the plaza briefing point"
]

var player: ShadowFrontPlayer
var companion: ShadowFrontCompanion
var objective_label: Label
var prompt_label: Label
var briefing_layer: CanvasLayer
var debrief_layer: CanvasLayer
var pause_layer: CanvasLayer
var objective_index: int = 0
var is_paused: bool = false
var saved_mission_complete: bool = false
var optional_note_found: bool = false

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
	environment.background_color = Color(0.045, 0.065, 0.078)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.58, 0.64, 0.66)
	environment.ambient_light_energy = 0.82
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = environment
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-38, -28, 0)
	sun.light_energy = 0.5
	sun.shadow_enabled = false
	add_child(sun)

func _create_world() -> void:
	_add_box("Archive district ground", Vector3(0, -0.15, 0), Vector3(48, 0.3, 54), Color(0.17, 0.19, 0.19))
	_add_box("Records annex", Vector3(-10, 2.5, -11), Vector3(13, 5, 10), Color(0.29, 0.34, 0.34))
	_add_box("Records roof", Vector3(-10, 5.1, -11), Vector3(13.5, 0.3, 10.5), WALL)
	_add_box("Annex entrance frame", Vector3(-10, 1.2, -5.85), Vector3(2.4, 2.4, 0.18), ACCENT, false)
	_add_label("LARKSPUR RECORDS ANNEX", Vector3(-10, 4.0, -5.6), 18, Color(0.83, 0.88, 0.83))
	_add_box("Ledger office", Vector3(10, 2.4, -11), Vector3(13, 4.8, 10), Color(0.25, 0.30, 0.32))
	_add_box("Ledger roof", Vector3(10, 4.9, -11), Vector3(13.5, 0.3, 10.5), WALL)
	_add_label("PUBLIC RECORDS", Vector3(10, 3.8, -5.7), 18, Color(0.83, 0.88, 0.83))
	_add_box("Witness pavilion", Vector3(10, 1.5, 10), Vector3(10, 0.25, 5), WALL)
	_add_box("Pavilion post A", Vector3(5.3, 1.2, 10), Vector3(0.2, 2.4, 0.2), ACCENT)
	_add_box("Pavilion post B", Vector3(14.7, 1.2, 10), Vector3(0.2, 2.4, 0.2), ACCENT)
	_add_label("COMMUNITY WITNESS DESK", Vector3(10, 3.0, 7.2), 16, Color(0.92, 0.77, 0.50))
	_add_box("Dispatch ledger terminal", Vector3(10, 0.75, -8.2), Vector3(1.4, 1.5, 0.8), WALL)
	_add_box("Ledger screen", Vector3(10, 1.65, -8.62), Vector3(1.0, 0.55, 0.1), Color(0.20, 0.43, 0.42), false)
	_add_label("PRESS E  /  COMPARE RECORDS", Vector3(10, 2.65, -8.0), 13, Color(0.68, 0.88, 0.82))
	_add_box("Community notice board", Vector3(-1, 1.3, 4), Vector3(3.8, 2.6, 0.25), Color(0.37, 0.29, 0.21))
	_add_label("COMMUNITY NOTICES", Vector3(-1, 3.0, 3.75), 14, Color(0.91, 0.79, 0.57))
	_add_box("Plaza shelter roof", Vector3(0, 2.4, 21), Vector3(14, 0.25, 4), WALL)
	_add_box("Plaza post left", Vector3(-6.5, 1.2, 21), Vector3(0.2, 2.4, 0.2), ACCENT)
	_add_box("Plaza post right", Vector3(6.5, 1.2, 21), Vector3(0.2, 2.4, 0.2), ACCENT)
	_add_label("TEAM BRIEFING POINT", Vector3(0, 3.5, 18.5), 19, Color(0.94, 0.77, 0.48))
	_add_box("North boundary", Vector3(0, 2, -27), Vector3(48, 4, 0.5), WALL)
	_add_box("West boundary", Vector3(-24, 2, 0), Vector3(0.5, 4, 54), WALL)
	_add_box("East boundary", Vector3(24, 2, 0), Vector3(0.5, 4, 54), WALL)
	_add_box("Street divider", Vector3(0, 0.3, -1), Vector3(0.25, 0.6, 42), Color(0.33, 0.34, 0.31), false)
	_add_label("PAPER TRAILS  /  DISTRICT 03", Vector3(0, 2.8, -20), 17, Color(0.75, 0.83, 0.82))

func _add_box(label_text: String, at: Vector3, dimensions: Vector3, tint: Color, solid: bool = true) -> void:
	var root: Node3D
	if solid:
		var body := StaticBody3D.new()
		body.name = label_text
		root = body
	else:
		root = Node3D.new()
		root.name = label_text
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
	player.position = Vector3(0, 0, 16)
	add_child(player)

func _create_companion() -> void:
	companion = ShadowFrontCompanion.new()
	companion.name = "SquadCompanion"
	companion.follow_target = player
	companion.position = Vector3(2, 0, 18)
	add_child(companion)

func _create_hud() -> void:
	var layer := CanvasLayer.new()
	var panel := ColorRect.new()
	panel.position = Vector2(18, 18)
	panel.size = Vector2(680, 126)
	panel.color = Color(0.02, 0.035, 0.045, 0.84)
	layer.add_child(panel)
	var heading := Label.new()
	heading.position = Vector2(14, 10)
	heading.size = Vector2(650, 28)
	heading.text = "PROJECT: SHADOW FRONT  /  03 — PAPER TRAILS"
	heading.add_theme_font_size_override("font_size", 16)
	panel.add_child(heading)
	objective_label = Label.new()
	objective_label.position = Vector2(14, 46)
	objective_label.size = Vector2(650, 30)
	objective_label.add_theme_font_size_override("font_size", 16)
	objective_label.add_theme_color_override("font_color", Color(1, 0.79, 0.45))
	panel.add_child(objective_label)
	prompt_label = Label.new()
	prompt_label.position = Vector2(14, 84)
	prompt_label.size = Vector2(650, 24)
	prompt_label.text = "WASD Move  •  Mouse Look  •  E Interact  •  P Pause"
	prompt_label.add_theme_font_size_override("font_size", 14)
	panel.add_child(prompt_label)
	add_child(layer)
	_refresh_objective_label()

func _refresh_objective_label() -> void:
	if objective_index >= OBJECTIVES.size():
		objective_label.text = "MISSION COMPLETE  |  Evidence verified"
	else:
		objective_label.text = "OBJECTIVE %d / 5  |  %s" % [objective_index + 1, OBJECTIVES[objective_index]]

func _show_briefing() -> void:
	briefing_layer = _make_overlay("MISSION BRIEFING", "PAPER TRAILS", "The Larkspur dispatch receipt points to a second set of records. Meet archivist Imani, compare the district ledger, and ask a local witness to verify the timeline. The evidence matters more than an easy conclusion.\n\nOptional: read the community notice board for context. No optional item is required to finish the mission.")
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
	prompt.add_theme_color_override("font_color", Color(1, 0.78, 0.43))
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
		_interact()

func _process(_delta: float) -> void:
	if is_instance_valid(briefing_layer) or is_instance_valid(debrief_layer) or is_paused:
		return
	if objective_index == 0 and player.global_position.distance_to(Vector3(-10, 0, -5)) < 5.0:
		_complete_objective()
	elif objective_index == 4 and player.global_position.distance_to(Vector3(0, 0, 20)) < 5.0:
		_complete_objective()

func _interact() -> void:
	if objective_index == 1 and player.global_position.distance_to(Vector3(-10, 0, -5)) < 5.0:
		prompt_label.text = "IMANI  |  The original ledger was copied before the dispatch amendment."
		_complete_objective()
	elif objective_index == 2 and player.global_position.distance_to(Vector3(10, 0, -8)) < 4.5:
		prompt_label.text = "LEDGER COMPARED  |  Amendment timestamp conflicts with the signed paper copy."
		_complete_objective()
	elif objective_index == 3 and player.global_position.distance_to(Vector3(10, 0, 10)) < 5.0:
		prompt_label.text = "WITNESS STATEMENT  |  The courier confirms the paper copy was sealed earlier."
		_complete_objective()
	elif not optional_note_found and player.global_position.distance_to(Vector3(-1, 0, 4)) < 4.0:
		optional_note_found = true
		prompt_label.text = "OPTIONAL NOTE FOUND  |  Residents logged the blackout before the public alert."
	elif is_instance_valid(companion) and player.global_position.distance_to(companion.global_position) < 4.0:
		prompt_label.text = "ELIAS  |  The signed copy gives us a second independent timestamp."

func _complete_objective() -> void:
	if objective_index >= OBJECTIVES.size():
		return
	objective_index += 1
	_save_progress()
	_refresh_objective_label()
	if objective_index >= OBJECTIVES.size():
		saved_mission_complete = true
		_save_progress()
		_show_debrief()

func _show_debrief() -> void:
	saved_mission_complete = true
	_save_progress()
	debrief_layer = _make_overlay("FIELD REPORT", "TWO RECORDS, ONE DISCREPANCY", "The archive ledger and the sealed paper copy disagree about when the dispatch was amended. A local witness confirms the paper record existed earlier. The evidence now points to deliberate record changes, but it still does not identify who ordered them.\n\nElias: \"We have a pattern. We still don't have a name.\"\n\nMISSION COMPLETE  /  WITNESS ACCOUNT RECORDED  /  EVIDENCE PRESERVED")
	player.set_physics_process(false)
	companion.set_process(false)
	player.mouse_captured = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

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
	heading.text = "FIELD MENU  /  PAPER TRAILS"
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

func _load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK or config.get_value(SAVE_SECTION, "mission_id", "") != "paper_trails":
		return
	objective_index = clampi(int(config.get_value(SAVE_SECTION, "objective_index", 0)), 0, OBJECTIVES.size())
	saved_mission_complete = bool(config.get_value(SAVE_SECTION, "mission_complete", false))
	if saved_mission_complete:
		objective_index = OBJECTIVES.size()
	_refresh_objective_label()

func _save_progress() -> void:
	var config := ConfigFile.new()
	var load_error := config.load(SAVE_PATH)
	if load_error != OK and load_error != ERR_FILE_NOT_FOUND:
		push_warning("Could not read campaign save: %s" % error_string(load_error))
		return
	config.set_value(SAVE_SECTION, "mission_id", "paper_trails")
	config.set_value(SAVE_SECTION, "objective_index", clampi(objective_index, 0, OBJECTIVES.size()))
	config.set_value(SAVE_SECTION, "mission_complete", saved_mission_complete)
	var save_error := config.save(SAVE_PATH)
	if save_error != OK:
		push_warning("Could not save Paper Trails progress: %s" % error_string(save_error))
