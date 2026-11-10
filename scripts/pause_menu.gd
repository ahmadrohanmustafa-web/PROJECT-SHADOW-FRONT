extends CanvasLayer
class_name ShadowFrontPauseMenu

var player: ShadowFrontPlayer
var save_system: ShadowFrontSaveSystem
var mission_manager: ShadowFrontMissionManager
var world_environment: WorldEnvironment
var menu_root: Control
var sensitivity_slider: HSlider
var low_detail_toggle: CheckButton
var is_open: bool = false
const SETTINGS_PATH := "user://shadow_front_settings.cfg"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	_build_menu()
	_load_settings()
	visible = false

func configure(target_player: ShadowFrontPlayer, saves: ShadowFrontSaveSystem, mission: ShadowFrontMissionManager, environment_node: WorldEnvironment) -> void:
	player = target_player
	save_system = saves
	mission_manager = mission
	world_environment = environment_node

func toggle_menu() -> void:
	if is_open:
		close_menu()
	else:
		open_menu()

func open_menu() -> void:
	if is_open:
		return
	is_open = true
	visible = true
	if is_instance_valid(player):
		player.set_physics_process(false)
		player.mouse_captured = false
	if get_tree().current_scene != null:
		var squad := get_tree().current_scene.get_node_or_null("SquadCompanion")
		if squad != null:
			squad.set_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_menu() -> void:
	if not is_open:
		return
	is_open = false
	visible = false
	if is_instance_valid(player):
		player.set_physics_process(true)
		player.mouse_captured = true
	if get_tree().current_scene != null:
		var squad := get_tree().current_scene.get_node_or_null("SquadCompanion")
		if squad != null:
			squad.set_process(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _build_menu() -> void:
	menu_root = Control.new()
	menu_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(menu_root)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.008, 0.015, 0.022, 0.91)
	menu_root.add_child(shade)
	var panel := PanelContainer.new()
	panel.position = Vector2(350.0, 105.0)
	panel.size = Vector2(580.0, 510.0)
	menu_root.add_child(panel)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18)
	panel.add_child(layout)
	var heading := Label.new()
	heading.text = "FIELD MENU"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 30)
	layout.add_child(heading)
	var subtitle := Label.new()
	subtitle.text = "PROJECT: SHADOW FRONT  /  NORTHSTAR"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(subtitle)
	var resume := Button.new()
	resume.text = "RESUME  [P]"
	resume.custom_minimum_size.y = 48
	resume.pressed.connect(close_menu)
	layout.add_child(resume)
	var save := Button.new()
	save.text = "SAVE CURRENT PROGRESS"
	save.custom_minimum_size.y = 42
	save.pressed.connect(_save_now)
	layout.add_child(save)
	var settings_title := Label.new()
	settings_title.text = "DISPLAY & CONTROLS"
	settings_title.add_theme_font_size_override("font_size", 20)
	layout.add_child(settings_title)
	low_detail_toggle = CheckButton.new()
	low_detail_toggle.text = "LOW DETAIL MODE  (reduce fog and environment cost)"
	low_detail_toggle.toggled.connect(_on_low_detail_changed)
	layout.add_child(low_detail_toggle)
	var sensitivity_label := Label.new()
	sensitivity_label.text = "MOUSE SENSITIVITY"
	layout.add_child(sensitivity_label)
	sensitivity_slider = HSlider.new()
	sensitivity_slider.min_value = 0.0008
	sensitivity_slider.max_value = 0.004
	sensitivity_slider.step = 0.0001
	sensitivity_slider.custom_minimum_size.y = 28
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	layout.add_child(sensitivity_slider)
	var footer := Label.new()
	footer.text = "Settings are saved locally. Press P to return to the mission."
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(footer)

func _save_now() -> void:
	if is_instance_valid(save_system) and is_instance_valid(mission_manager):
		save_system.save_progress(mission_manager.current_objective_index, mission_manager.checkpoint_position, mission_manager.is_complete)

func _on_low_detail_changed(enabled: bool) -> void:
	if is_instance_valid(world_environment) and world_environment.environment != null:
		world_environment.environment.fog_enabled = not enabled
		world_environment.environment.ambient_light_energy = 0.52 if enabled else 0.72
	_save_settings()

func _on_sensitivity_changed(value: float) -> void:
	if is_instance_valid(player):
		player.mouse_sensitivity = value
	_save_settings()

func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		sensitivity_slider.value = 0.0018
		low_detail_toggle.button_pressed = false
		return
	sensitivity_slider.value = float(config.get_value("settings", "mouse_sensitivity", 0.0018))
	low_detail_toggle.button_pressed = bool(config.get_value("settings", "low_detail", false))
	_apply_loaded_settings()

func _apply_loaded_settings() -> void:
	if is_instance_valid(player):
		player.mouse_sensitivity = sensitivity_slider.value
	if is_instance_valid(world_environment) and world_environment.environment != null:
		world_environment.environment.fog_enabled = not low_detail_toggle.button_pressed
		world_environment.environment.ambient_light_energy = 0.52 if low_detail_toggle.button_pressed else 0.72

func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("settings", "mouse_sensitivity", sensitivity_slider.value)
	config.set_value("settings", "low_detail", low_detail_toggle.button_pressed)
	config.save(SETTINGS_PATH)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_P:
		toggle_menu()
		get_viewport().set_input_as_handled()
