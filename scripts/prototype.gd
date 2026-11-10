extends Node3D

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")

const CONCRETE := Color(0.20, 0.23, 0.24)
const DARK_CONCRETE := Color(0.12, 0.15, 0.17)
const WARM_METAL := Color(0.42, 0.34, 0.25)
const PALE_METAL := Color(0.36, 0.40, 0.41)
const ACCENT := Color(0.72, 0.48, 0.20)

var mission_status_label: Label
var player: ShadowFrontPlayer
var mission_manager: ShadowFrontMissionManager

func _ready() -> void:
	_create_environment()
	_create_level()
	_create_player()
	_create_hud()
	_create_mission_manager()
	_create_objective_triggers()

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
	mission_manager.start_mission([
		"Reach the warehouse loading bay",
		"Reach the data terminal inside the warehouse"
	], player.global_position)

func _create_objective_triggers() -> void:
	_add_objective_trigger("LoadingBayObjectiveTrigger", Vector3(0.0, 1.2, -14.0), 0)
	_add_objective_trigger("DataTerminalObjectiveTrigger", Vector3(0.0, 1.2, -24.0), 1)

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

func _on_mission_objective_changed(index: int, description: String) -> void:
	mission_status_label.text = "%s  |  %s" % [mission_manager.get_objective_counter(), description]
	mission_status_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.42))

func _on_mission_completed() -> void:
	mission_status_label.text = "MISSION COMPLETE  |  Northstar Terminal secured"
	mission_status_label.add_theme_color_override("font_color", Color(0.55, 0.88, 0.62))

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
	label.size = Vector2(570.0, 76.0)
	label.text = "PROJECT: SHADOW FRONT  |  NORTHSTAR TERMINAL\nWASD Move   SHIFT Sprint   SPACE Jump\nCTRL Hold / C Toggle Crouch   Mouse Look   ESC Release Mouse"
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
