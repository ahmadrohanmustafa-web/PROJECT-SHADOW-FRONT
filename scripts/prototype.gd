extends Node3D

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")

func _ready() -> void:
	_create_environment()
	_create_test_geometry()
	_create_player()
	_create_hud()

func _create_environment() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.48, 0.53, 0.62)
	environment.ambient_light_energy = 0.65
	world_environment.environment = environment
	add_child(world_environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52.0, -28.0, 0.0)
	sun.light_energy = 0.8
	sun.shadow_enabled = false
	add_child(sun)

func _create_test_geometry() -> void:
	_add_box("Ground", Vector3(0.0, -0.15, 0.0), Vector3(32.0, 0.3, 32.0), Color(0.19, 0.22, 0.23))
	_add_box("Low platform", Vector3(0.0, 0.35, -5.0), Vector3(3.0, 0.7, 2.0), Color(0.34, 0.37, 0.39))
	_add_box("Tall block A", Vector3(-4.0, 1.0, -7.0), Vector3(2.0, 2.0, 2.0), Color(0.28, 0.32, 0.35))
	_add_box("Tall block B", Vector3(4.0, 1.0, -8.0), Vector3(2.0, 2.0, 2.0), Color(0.28, 0.32, 0.35))
	_add_box("Crouch passage top", Vector3(0.0, 1.8, -10.0), Vector3(5.0, 0.35, 2.0), Color(0.38, 0.34, 0.29))
	_add_box("Crouch passage left", Vector3(-2.35, 0.9, -10.0), Vector3(0.3, 1.8, 2.0), Color(0.38, 0.34, 0.29))
	_add_box("Crouch passage right", Vector3(2.35, 0.9, -10.0), Vector3(0.3, 1.8, 2.0), Color(0.38, 0.34, 0.29))

func _add_box(box_name: String, box_position: Vector3, box_size: Vector3, box_color: Color) -> void:
	var body := StaticBody3D.new()
	body.name = box_name
	body.position = box_position

	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = box_size
	mesh_instance.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = box_color
	material.roughness = 0.92
	mesh_instance.material_override = material
	body.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = box_size
	collision.shape = box_shape
	body.add_child(collision)
	add_child(body)

func _create_player() -> void:
	var player := PLAYER_SCENE.instantiate()
	player.position = Vector3(0.0, 0.0, 5.0)
	add_child(player)

func _create_hud() -> void:
	var layer := CanvasLayer.new()
	var panel := ColorRect.new()
	panel.position = Vector2(18.0, 18.0)
	panel.size = Vector2(440.0, 104.0)
	panel.color = Color(0.025, 0.035, 0.045, 0.78)
	layer.add_child(panel)

	var label := Label.new()
	label.position = Vector2(32.0, 27.0)
	label.size = Vector2(410.0, 88.0)
	label.text = "SHADOW FRONT  |  MOVEMENT TEST\nWASD Move   SHIFT Sprint   SPACE Jump\nCTRL / C Crouch   Mouse Look   ESC Release Mouse"
	label.add_theme_color_override("font_color", Color(0.91, 0.94, 0.96))
	label.add_theme_font_size_override("font_size", 16)
	panel.add_child(label)
	add_child(layer)
