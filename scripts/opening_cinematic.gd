extends Control
## Lightweight, skippable opening cinematic for the first campaign chapter.
## Built entirely from native UI nodes so it remains compatible with the
## project's Godot Compatibility renderer and older integrated GPUs.

const FIRST_MISSION := "res://scenes/prototype.tscn"
const ACCENT := Color(0.88, 0.58, 0.27)
const PALE := Color(0.88, 0.91, 0.88)
const MUTED := Color(0.55, 0.66, 0.68)

var kicker: Label
var headline: Label
var body_copy: Label
var chapter_mark: Label
var skip_hint: Label
var progress_fill: ColorRect
var signal_bars: Array[ColorRect] = []
var elapsed := 0.0
var finished := false
var sequence_tween: Tween

func _ready() -> void:
	_build_cinematic()
	_run_sequence()

func _build_cinematic() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.012, 0.022, 0.029)
	add_child(backdrop)

	# Restrained horizon bands create depth without expensive 3D effects.
	_add_rect(Vector2(0, 365), Vector2(1280, 355), Color(0.025, 0.043, 0.049))
	_add_rect(Vector2(0, 364), Vector2(1280, 2), Color(0.22, 0.30, 0.31, 0.55))
	_add_rect(Vector2(0, 0), Vector2(1280, 92), Color(0.0, 0.0, 0.0, 0.52))
	_add_rect(Vector2(0, 628), Vector2(1280, 92), Color(0.0, 0.0, 0.0, 0.58))

	# Distant relay silhouettes and a thin amber warning light.
	_add_rect(Vector2(930, 250), Vector2(3, 115), Color(0.18, 0.27, 0.29))
	_add_rect(Vector2(905, 270), Vector2(52, 3), Color(0.18, 0.27, 0.29))
	_add_rect(Vector2(1020, 305), Vector2(2, 60), Color(0.15, 0.23, 0.25))
	_add_rect(Vector2(1010, 305), Vector2(22, 2), Color(0.15, 0.23, 0.25))
	_add_rect(Vector2(931, 255), Vector2(3, 7), ACCENT)

	var top_left := _label("VEYRA  /  FIELD OPERATIONS", 14, MUTED)
	top_left.position = Vector2(72, 42)
	top_left.size = Vector2(420, 24)
	add_child(top_left)

	var top_right := _label("SINGLE-PLAYER CAMPAIGN     •     01", 12, MUTED)
	top_right.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top_right.position = Vector2(780, 42)
	top_right.size = Vector2(428, 24)
	add_child(top_right)

	chapter_mark = _label("CHAPTER 01     /     COLD SIGNAL", 15, ACCENT)
	chapter_mark.position = Vector2(104, 190)
	chapter_mark.size = Vector2(600, 28)
	add_child(chapter_mark)

	kicker = _label("", 13, MUTED)
	kicker.position = Vector2(104, 247)
	kicker.size = Vector2(700, 24)
	add_child(kicker)

	headline = _label("", 43, PALE)
	headline.position = Vector2(100, 282)
	headline.size = Vector2(900, 112)
	headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	headline.add_theme_font_size_override("font_size", 43)
	add_child(headline)

	body_copy = _label("", 19, Color(0.72, 0.80, 0.80))
	body_copy.position = Vector2(105, 420)
	body_copy.size = Vector2(780, 82)
	body_copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_copy.add_theme_font_size_override("font_size", 19)
	add_child(body_copy)

	# Signal trace: a small animated visual motif, not a heavy particle effect.
	for i in range(24):
		var bar := ColorRect.new()
		bar.position = Vector2(930 + i * 9, 500)
		bar.size = Vector2(4, 8 + ((i * 17) % 28))
		bar.color = Color(0.34, 0.53, 0.53, 0.55)
		add_child(bar)
		signal_bars.append(bar)

	_add_rect(Vector2(104, 574), Vector2(1072, 2), Color(0.27, 0.36, 0.37, 0.65))
	progress_fill = _add_rect(Vector2(104, 573), Vector2(0, 4), ACCENT)
	skip_hint = _label("PRESS ENTER OR SPACE TO SKIP", 12, Color(0.55, 0.63, 0.64))
	skip_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	skip_hint.position = Vector2(820, 652)
	skip_hint.size = Vector2(388, 22)
	add_child(skip_hint)

	var footer := _label("PROJECT: SHADOW FRONT", 12, Color(0.40, 0.49, 0.51))
	footer.position = Vector2(72, 652)
	footer.size = Vector2(420, 22)
	add_child(footer)

func _process(delta: float) -> void:
	elapsed += delta
	for i in range(signal_bars.size()):
		var bar := signal_bars[i]
		var pulse := 0.5 + 0.5 * sin(elapsed * 2.1 + float(i) * 0.63)
		bar.size.y = 7.0 + pulse * float(8 + (i * 7) % 27)
		bar.position.y = 516.0 - bar.size.y

func _run_sequence() -> void:
	await _show_beat("INCOMING TRANSMISSION  /  02:14", "NORTHSTAR HAS GONE QUIET.", "A routine night shift. A missed check-in. Then every channel went silent.", 3.8)
	if finished: return
	await _show_beat("VEYRA  /  NORTHERN INDUSTRIAL CORRIDOR", "THE LAST SIGNAL WAS AUTHENTIC.", "The relay confirms the distress call came from inside the terminal. Its timestamp does not match the public record.", 4.2)
	if finished: return
	await _show_beat("FIELD TEAM  /  DEPLOYMENT AUTHORIZED", "FIND THE ORIGINAL RECORD.", "You are being sent to recover the incident log and establish what happened before the story changes again.", 4.2)
	if finished: return
	await _show_beat("CHAPTER 01  /  COLD SIGNAL", "SOMEONE CHANGED THE TIMELINE.", "Northstar Terminal  •  02:14 local time  •  Operation begins now.", 3.4)
	if finished: return
	_finish_intro()

func _show_beat(new_kicker: String, new_headline: String, new_body: String, hold_seconds: float) -> void:
	kicker.text = new_kicker
	headline.text = new_headline
	body_copy.text = new_body
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
	var fade := create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 0.45)
	await fade.finished
	if is_inside_tree():
		var error := get_tree().change_scene_to_file(FIRST_MISSION)
		if error != OK:
			push_error("Could not load the first mission: %s" % error_string(error))

func _add_rect(rect_position: Vector2, rect_size: Vector2, rect_color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.position = rect_position
	rect.size = rect_size
	rect.color = rect_color
	add_child(rect)
	return rect

func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
