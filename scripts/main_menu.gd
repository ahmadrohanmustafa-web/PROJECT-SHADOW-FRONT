extends Control

const PROTOTYPE_SCENE := "res://scenes/prototype.tscn"
const SAVE_PATH := "user://shadow_front_save.cfg"
const SAVE_SECTION := "northstar_first_contact"

var continue_button: Button
var mission_two_button: Button
var status_label: Label

func _ready() -> void:
	_build_interface()
	_refresh_continue_state()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _build_interface() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.018, 0.031, 0.041)
	add_child(background)

	var left_panel := ColorRect.new()
	left_panel.position = Vector2(0.0, 0.0)
	left_panel.size = Vector2(570.0, 720.0)
	left_panel.color = Color(0.035, 0.055, 0.065)
	add_child(left_panel)

	var top_rule := ColorRect.new()
	top_rule.position = Vector2(76.0, 92.0)
	top_rule.size = Vector2(5.0, 430.0)
	top_rule.color = Color(0.76, 0.48, 0.23)
	add_child(top_rule)

	var eyebrow := _make_label("ORIGINAL SINGLE-PLAYER CAMPAIGN", 16, Color(0.67, 0.78, 0.79))
	eyebrow.position = Vector2(108.0, 104.0)
	eyebrow.size = Vector2(420.0, 28.0)
	add_child(eyebrow)

	var title := _make_label("PROJECT:\nSHADOW FRONT", 52, Color(0.94, 0.92, 0.84))
	title.position = Vector2(104.0, 160.0)
	title.size = Vector2(450.0, 150.0)
	title.add_theme_font_size_override("font_size", 52)
	add_child(title)

	var divider := ColorRect.new()
	divider.position = Vector2(108.0, 337.0)
	divider.size = Vector2(390.0, 2.0)
	divider.color = Color(0.34, 0.43, 0.43)
	add_child(divider)

	var tagline := _make_label("TRUTH HAS A TIMESTAMP.", 20, Color(0.85, 0.70, 0.48))
	tagline.position = Vector2(108.0, 365.0)
	tagline.size = Vector2(400.0, 32.0)
	add_child(tagline)

	var description := _make_label("A routine communications failure becomes\na question of trust, evidence, and who\ncontrols the story.", 18, Color(0.72, 0.79, 0.80))
	description.position = Vector2(108.0, 414.0)
	description.size = Vector2(410.0, 100.0)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(description)

	var menu_panel := PanelContainer.new()
	menu_panel.position = Vector2(700.0, 150.0)
	menu_panel.size = Vector2(460.0, 420.0)
	add_child(menu_panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	menu_panel.add_child(layout)

	var menu_heading := _make_label("CAMPAIGN", 24, Color(0.91, 0.91, 0.85))
	menu_heading.custom_minimum_size.y = 42.0
	layout.add_child(menu_heading)

	continue_button = Button.new()
	continue_button.text = "CONTINUE MISSION"
	continue_button.custom_minimum_size = Vector2(0.0, 58.0)
	continue_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	continue_button.pressed.connect(_continue_campaign)
	layout.add_child(continue_button)

	var new_button := Button.new()
	new_button.text = "NEW CAMPAIGN"
	new_button.custom_minimum_size = Vector2(0.0, 58.0)
	new_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_button.pressed.connect(_start_new_campaign)
	layout.add_child(new_button)

	var mission_label := _make_label("AVAILABLE MISSION", 14, Color(0.68, 0.77, 0.77))
	mission_label.custom_minimum_size.y = 28.0
	layout.add_child(mission_label)

	var mission_card := PanelContainer.new()
	mission_card.custom_minimum_size.y = 82.0
	layout.add_child(mission_card)
	var mission_text := _make_label("01  /  NORTHSTAR: FIRST CONTACT\nNorthstar Terminal  •  Field operation", 16, Color(0.87, 0.88, 0.83))
	mission_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mission_card.add_child(mission_text)

	mission_two_button = Button.new()
	mission_two_button.text = "02  /  THE QUIET DISTRICT  —  LOCKED"
	mission_two_button.custom_minimum_size = Vector2(0.0, 48.0)
	mission_two_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mission_two_button.pressed.connect(_start_mission_two)
	layout.add_child(mission_two_button)

	var quit_button := Button.new()
	quit_button.text = "QUIT TO DESKTOP"
	quit_button.custom_minimum_size = Vector2(0.0, 46.0)
	quit_button.pressed.connect(get_tree().quit)
	layout.add_child(quit_button)

	status_label = _make_label("BUILD  0.1  /  PROTOTYPE", 13, Color(0.48, 0.59, 0.61))
	status_label.position = Vector2(700.0, 600.0)
	status_label.size = Vector2(460.0, 26.0)
	add_child(status_label)

	var footer := _make_label("WASD / MOUSE  •  SINGLE PLAYER  •  WINDOWS", 12, Color(0.42, 0.52, 0.55))
	footer.position = Vector2(76.0, 674.0)
	footer.size = Vector2(520.0, 22.0)
	add_child(footer)

func _make_label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _refresh_continue_state() -> void:
	var config := ConfigFile.new()
	var has_save := config.load(SAVE_PATH) == OK and config.get_value(SAVE_SECTION, "mission_id", "") == "northstar_first_contact"
	continue_button.disabled = not has_save
	if has_save:
		var objective := int(config.get_value(SAVE_SECTION, "objective_index", 0))
		var completed := bool(config.get_value(SAVE_SECTION, "mission_complete", false))
		status_label.text = "LOCAL SAVE FOUND  /  " + ("MISSION COMPLETE" if completed else "OBJECTIVE %d / 3" % (clampi(objective, 0, 2) + 1))
	else:
		status_label.text = "NO CAMPAIGN SAVE  /  READY TO DEPLOY"

func _continue_campaign() -> void:
	get_tree().change_scene_to_file(PROTOTYPE_SCENE)

func _start_mission_two() -> void:
	get_tree().change_scene_to_file("res://scenes/mission_02.tscn")

func _start_new_campaign() -> void:
	var config := ConfigFile.new()
	var load_error := config.load(SAVE_PATH)
	if load_error == OK:
		config.erase_section(SAVE_SECTION)
		var save_error := config.save(SAVE_PATH)
		if save_error != OK:
			status_label.text = "SAVE RESET FAILED  /  " + error_string(save_error)
			return
	elif load_error != ERR_FILE_NOT_FOUND:
		status_label.text = "SAVE COULD NOT BE READ  /  " + error_string(load_error)
		return
	get_tree().change_scene_to_file(PROTOTYPE_SCENE)
