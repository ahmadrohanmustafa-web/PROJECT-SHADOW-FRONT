extends Node3D
## Cold Signal: low-cost 3D establishing shot for the campaign opening.
## Uses primitive meshes and one camera; no particles, post-processing, or heavy shaders.

const FIRST_MISSION := "res://scenes/prototype.tscn"
const ACCENT := Color(0.88, 0.58, 0.27)
const PALE := Color(0.88, 0.91, 0.88)
const MUTED := Color(0.55, 0.66, 0.68)

var camera: Camera3D
var overlay: Control
var kicker: Label
var headline: Label
var body_copy: Label
var progress_fill: ColorRect
var subtitle_speaker: Label
var subtitle_line: Label
var elias: ShadowFrontCompanion
var signal_bars: Array[ColorRect] = []
var elapsed := 0.0
var finished := false
var sequence_tween: Tween
var camera_tween: Tween
var operator_root: Node3D

func _ready() -> void:
	_build_world()
	_build_camera()
	_build_overlay()
	_run_sequence()

func _build_world() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.025, 0.045, 0.058)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.48, 0.57, 0.62)
	environment.ambient_light_energy = 0.7
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.20, 0.29, 0.33)
	environment.fog_density = 0.012
	world.environment = environment
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-24.0, -28.0, 0.0)
	sun.light_color = Color(0.60, 0.72, 0.78)
	sun.light_energy = 0.55
	sun.shadow_enabled = false
	add_child(sun)

	_add_box("Wet terminal apron", Vector3(0.0, -0.25, -8.0), Vector3(54.0, 0.5, 70.0), Color(0.075, 0.105, 0.115))
	_add_box("North warehouse", Vector3(0.0, 5.0, -31.0), Vector3(30.0, 10.0, 5.0), Color(0.16, 0.21, 0.23))
	_add_box("Warehouse roof lip", Vector3(0.0, 10.1, -28.2), Vector3(31.0, 0.35, 0.7), Color(0.09, 0.13, 0.15))
	_add_box("Loading bay shadow", Vector3(0.0, 3.4, -28.35), Vector3(10.0, 6.6, 0.18), Color(0.025, 0.039, 0.045))
	_add_box("Bay left pillar", Vector3(-5.5, 4.0, -27.9), Vector3(0.55, 8.0, 0.65), Color(0.30, 0.34, 0.33))
	_add_box("Bay right pillar", Vector3(5.5, 4.0, -27.9), Vector3(0.55, 8.0, 0.65), Color(0.30, 0.34, 0.33))
	_add_box("Terminal office", Vector3(-19.0, 3.2, -19.0), Vector3(8.0, 6.4, 12.0), Color(0.12, 0.18, 0.20))
	_add_box("Office roof", Vector3(-19.0, 6.5, -19.0), Vector3(8.5, 0.35, 12.5), Color(0.07, 0.11, 0.13))
	_add_box("Container left", Vector3(-13.0, 1.6, -5.0), Vector3(7.0, 3.2, 4.0), Color(0.18, 0.27, 0.28))
	_add_box("Container right", Vector3(14.0, 1.6, -11.0), Vector3(7.0, 3.2, 4.0), Color(0.25, 0.23, 0.18))
	_add_box("Container right upper", Vector3(14.0, 5.0, -11.0), Vector3(7.0, 3.2, 4.0), Color(0.16, 0.22, 0.23))

	for x in [-23.0, 23.0]:
		_add_box("Perimeter fence post", Vector3(x, 2.0, -7.0), Vector3(0.22, 4.0, 0.22), Color(0.12, 0.17, 0.18))
		_add_box("Perimeter fence rail", Vector3(x, 3.8, -7.0), Vector3(0.18, 0.18, 43.0), Color(0.12, 0.17, 0.18))
	for z in [-25.0, -18.0, -11.0, -4.0, 3.0, 10.0]:
		_add_box("Apron marking", Vector3(0.0, 0.012, z), Vector3(0.16, 0.025, 4.0), Color(0.55, 0.43, 0.25))

	# Two unlit mast silhouettes and small amber warning lamps.
	for x in [-17.0, 17.0]:
		_add_box("Floodlight mast", Vector3(x, 6.0, -14.0), Vector3(0.22, 12.0, 0.22), Color(0.10, 0.15, 0.17))
		_add_box("Floodlight arm", Vector3(x * 0.94, 11.6, -14.0), Vector3(1.8, 0.18, 0.22), Color(0.13, 0.18, 0.19))
		_add_box("Warning lamp", Vector3(x * 0.94, 11.35, -14.0), Vector3(0.32, 0.18, 0.32), ACCENT)

	_build_operator()
	_build_elias()

func _build_operator() -> void:
	operator_root = Node3D.new()
	operator_root.name = "FieldOperatorSilhouette"
	operator_root.position = Vector3(0.0, 0.0, -1.7)
	add_child(operator_root)
	var uniform := Color(0.045, 0.065, 0.071)
	_add_character_mesh(CapsuleMesh.new(), operator_root, Vector3(0.0, 1.12, 0.0), Vector3(0.68, 1.0, 0.42), uniform)
	_add_character_mesh(SphereMesh.new(), operator_root, Vector3(0.0, 2.05, 0.0), Vector3(0.27, 0.30, 0.27), Color(0.07, 0.085, 0.09))
	_add_character_mesh(CapsuleMesh.new(), operator_root, Vector3(-0.43, 1.08, 0.02), Vector3(0.22, 0.78, 0.22), uniform)
	_add_character_mesh(CapsuleMesh.new(), operator_root, Vector3(0.43, 1.08, 0.02), Vector3(0.22, 0.78, 0.22), uniform)
	_add_character_mesh(CapsuleMesh.new(), operator_root, Vector3(-0.19, 0.36, 0.0), Vector3(0.24, 0.72, 0.25), uniform)
	_add_character_mesh(CapsuleMesh.new(), operator_root, Vector3(0.19, 0.36, 0.0), Vector3(0.24, 0.72, 0.25), uniform)
	_add_box_child(operator_root, "Backpack", Vector3(0.0, 1.25, 0.27), Vector3(0.48, 0.65, 0.24), Color(0.075, 0.10, 0.10))

func _build_elias() -> void:
	# Reuse the established companion character so the opening matches the
	# squad partner encountered in the playable mission.
	elias = ShadowFrontCompanion.new()
	elias.name = "EliasRook"
	elias.position = Vector3(1.75, 0.0, -0.5)
	elias.rotation.y = deg_to_rad(-8.0)
	elias.scale = Vector3.ONE * 0.92
	add_child(elias)

func _add_character_mesh(mesh: PrimitiveMesh, parent: Node3D, mesh_position: Vector3, mesh_scale: Vector3, tint: Color) -> void:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = mesh_position
	instance.scale = mesh_scale
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 1.0
	instance.material_override = material
	parent.add_child(instance)

func _add_box_child(parent: Node3D, node_name: String, box_position: Vector3, box_size: Vector3, tint: Color) -> void:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = box_size
	instance.mesh = mesh
	instance.position = box_position
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 1.0
	instance.material_override = material
	parent.add_child(instance)

func _add_box(node_name: String, box_position: Vector3, box_size: Vector3, tint: Color) -> void:
	_add_box_child(self, node_name, box_position, box_size, tint)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "OpeningCamera"
	camera.position = Vector3(0.0, 3.2, 16.0)
	camera.fov = 58.0
	add_child(camera)
	camera.look_at(Vector3(0.0, 2.0, -16.0), Vector3.UP)
	camera.current = true
	camera_tween = create_tween()
	camera_tween.set_trans(Tween.TRANS_SINE)
	camera_tween.set_ease(Tween.EASE_IN_OUT)
	camera_tween.tween_property(camera, "position", Vector3(0.0, 2.7, 7.0), 15.0)

func _build_overlay() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 5
	add_child(canvas)
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas.add_child(overlay)

	_add_overlay_rect(Vector2(0, 0), Vector2(1280, 94), Color(0.0, 0.0, 0.0, 0.48))
	_add_overlay_rect(Vector2(0, 620), Vector2(1280, 100), Color(0.0, 0.0, 0.0, 0.58))
	_add_overlay_rect(Vector2(0, 0), Vector2(1280, 720), Color(0.005, 0.012, 0.018, 0.14))

	var top_left := _label("VEYRA  /  FIELD OPERATIONS", 14, MUTED)
	top_left.position = Vector2(72, 40)
	top_left.size = Vector2(420, 24)
	overlay.add_child(top_left)
	var top_right := _label("SINGLE-PLAYER CAMPAIGN     •     01", 12, MUTED)
	top_right.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top_right.position = Vector2(780, 40)
	top_right.size = Vector2(428, 24)
	overlay.add_child(top_right)

	var chapter := _label("CHAPTER 01     /     COLD SIGNAL", 15, ACCENT)
	chapter.position = Vector2(104, 190)
	chapter.size = Vector2(600, 28)
	overlay.add_child(chapter)
	kicker = _label("", 13, MUTED)
	kicker.position = Vector2(104, 247)
	kicker.size = Vector2(700, 24)
	overlay.add_child(kicker)
	headline = _label("", 43, PALE)
	headline.position = Vector2(100, 282)
	headline.size = Vector2(900, 112)
	headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	headline.add_theme_font_size_override("font_size", 43)
	overlay.add_child(headline)
	body_copy = _label("", 19, Color(0.80, 0.86, 0.86))
	body_copy.position = Vector2(105, 420)
	body_copy.size = Vector2(780, 82)
	body_copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_copy.add_theme_font_size_override("font_size", 19)
	overlay.add_child(body_copy)

	for i in range(24):
		var bar := ColorRect.new()
		bar.position = Vector2(930 + i * 9, 500)
		bar.size = Vector2(4, 8 + ((i * 17) % 28))
		bar.color = Color(0.55, 0.76, 0.75, 0.7)
		overlay.add_child(bar)
		signal_bars.append(bar)

	_add_overlay_rect(Vector2(104, 516), Vector2(790, 66), Color(0.015, 0.028, 0.035, 0.78))
	subtitle_speaker = _label("", 12, ACCENT)
	subtitle_speaker.position = Vector2(124, 524)
	subtitle_speaker.size = Vector2(740, 18)
	overlay.add_child(subtitle_speaker)
	subtitle_line = _label("", 17, PALE)
	subtitle_line.position = Vector2(124, 545)
	subtitle_line.size = Vector2(740, 30)
	subtitle_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay.add_child(subtitle_line)

	_add_overlay_rect(Vector2(104, 604), Vector2(1072, 2), Color(0.55, 0.66, 0.66, 0.5))
	progress_fill = _add_overlay_rect(Vector2(104, 603), Vector2(0, 4), ACCENT)
	var skip := _label("PRESS ENTER OR SPACE TO SKIP", 12, Color(0.70, 0.77, 0.77))
	skip.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	skip.position = Vector2(820, 652)
	skip.size = Vector2(388, 22)
	overlay.add_child(skip)
	var footer := _label("PROJECT: SHADOW FRONT", 12, Color(0.60, 0.68, 0.68))
	footer.position = Vector2(72, 652)
	footer.size = Vector2(420, 22)
	overlay.add_child(footer)

func _process(delta: float) -> void:
	elapsed += delta
	for i in range(signal_bars.size()):
		var bar := signal_bars[i]
		var pulse := 0.5 + 0.5 * sin(elapsed * 2.1 + float(i) * 0.63)
		bar.size.y = 7.0 + pulse * float(8 + (i * 7) % 27)
		bar.position.y = 516.0 - bar.size.y
	if is_instance_valid(operator_root):
		operator_root.rotation.y = sin(elapsed * 0.35) * 0.025

func _run_sequence() -> void:
	await _show_beat("INCOMING TRANSMISSION  /  02:14", "NORTHSTAR HAS GONE QUIET.", "A routine night shift. A missed check-in. Then every channel went silent.", 3.8, "ELIAS ROOK  /  COMMS", "Northstar, this is Field Team. Do you read?")
	if finished: return
	await _show_beat("VEYRA  /  NORTHERN INDUSTRIAL CORRIDOR", "THE LAST SIGNAL WAS AUTHENTIC.", "The relay confirms the distress call came from inside the terminal. Its timestamp does not match the public record.", 4.2, "ELIAS ROOK  /  COMMS", "That timestamp is two minutes ahead of the relay log.")
	if finished: return
	await _show_beat("FIELD TEAM  /  DEPLOYMENT AUTHORIZED", "FIND THE ORIGINAL RECORD.", "You are being sent to recover the incident log and establish what happened before the story changes again.", 4.2, "ELIAS ROOK  /  COMMS", "I'll watch the comms. You get the original record.")
	if finished: return
	await _show_beat("CHAPTER 01  /  COLD SIGNAL", "SOMEONE CHANGED THE TIMELINE.", "Northstar Terminal  •  02:14 local time  •  Operation begins now.", 3.4, "ELIAS ROOK  /  COMMS", "Let's find out who changed it.")
	if finished: return
	_finish_intro()

func _show_beat(new_kicker: String, new_headline: String, new_body: String, hold_seconds: float, speaker: String, dialogue: String) -> void:
	kicker.text = new_kicker
	headline.text = new_headline
	body_copy.text = new_body
	subtitle_speaker.text = speaker
	subtitle_line.text = dialogue
	subtitle_speaker.modulate.a = 0.0
	subtitle_line.modulate.a = 0.0
	kicker.modulate.a = 0.0
	headline.modulate.a = 0.0
	body_copy.modulate.a = 0.0
	if sequence_tween and sequence_tween.is_running():
		sequence_tween.kill()
	sequence_tween = create_tween()
	sequence_tween.set_parallel(true)
	sequence_tween.tween_property(kicker, "modulate:a", 1.0, 0.65)
	sequence_tween.tween_property(headline, "modulate:a", 1.0, 0.85).set_delay(0.12)
	sequence_tween.tween_property(body_copy, "modulate:a", 1.0, 0.9).set_delay(0.3)
	sequence_tween.tween_property(subtitle_speaker, "modulate:a", 1.0, 0.65).set_delay(0.45)
	sequence_tween.tween_property(subtitle_line, "modulate:a", 1.0, 0.75).set_delay(0.55)
	var target_width := 1072.0 * clampf((elapsed + hold_seconds) / 15.6, 0.0, 1.0)
	sequence_tween.tween_property(progress_fill, "size:x", target_width, hold_seconds)
	await get_tree().create_timer(hold_seconds).timeout

func _unhandled_input(event: InputEvent) -> void:
	if finished:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE:
			_finish_intro()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed:
		_finish_intro()
		get_viewport().set_input_as_handled()

func _finish_intro() -> void:
	if finished:
		return
	finished = true
	if sequence_tween and sequence_tween.is_running():
		sequence_tween.kill()
	if camera_tween and camera_tween.is_running():
		camera_tween.kill()
	var fade := create_tween()
	fade.tween_property(overlay, "modulate:a", 0.0, 0.45)
	await fade.finished
	if is_inside_tree():
		var error := get_tree().change_scene_to_file(FIRST_MISSION)
		if error != OK:
			push_error("Could not load the first mission: %s" % error_string(error))

func _add_overlay_rect(rect_position: Vector2, rect_size: Vector2, rect_color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.position = rect_position
	rect.size = rect_size
	rect.color = rect_color
	overlay.add_child(rect)
	return rect

func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
