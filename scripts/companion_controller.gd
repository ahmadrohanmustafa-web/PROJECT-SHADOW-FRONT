extends Node3D
class_name ShadowFrontCompanion

## Lightweight, non-combat squad partner for the Northstar prototype.
## The companion follows at a comfortable distance and never blocks the player.

@export var follow_speed: float = 3.6
@export var follow_distance: float = 2.4
@export var catch_up_distance: float = 8.0

var follow_target: Node3D
var body_mesh: MeshInstance3D
var head_mesh: MeshInstance3D
var dialogue_index: int = 0
var nameplate: Label3D
var radio_lines: Array[String] = [
	"I'm with you. Let's bring that data home.",
	"Keep moving. The rendezvous is back across the yard.",
	"Terminal is behind us. Stay close until we're clear."
]

func get_radio_line(objective_index: int = -1) -> String:
	var contextual_index := dialogue_index
	if objective_index == 0:
		contextual_index = 1
	elif objective_index == 1:
		contextual_index = 2
	elif objective_index == 2:
		contextual_index = 3 + (dialogue_index % 2)
	var line := radio_lines[contextual_index % radio_lines.size()]
	dialogue_index += 1
	return line

func _ready() -> void:
	_build_character()

func _process(delta: float) -> void:
	if not is_instance_valid(follow_target):
		return
	var behind_target := follow_target.global_transform.basis * Vector3(1.25, 0.0, 2.0)
	var desired_position := follow_target.global_position + behind_target
	desired_position.y = 0.0
	desired_position += _get_obstacle_avoidance(desired_position)
	var distance := global_position.distance_to(desired_position)
	if distance > follow_distance:
		var speed_scale := 1.0
		if distance > catch_up_distance:
			speed_scale = 1.35
		global_position = global_position.move_toward(desired_position, follow_speed * speed_scale * delta)
	var look_target := follow_target.global_position
	look_target.y = global_position.y
	if global_position.distance_to(look_target) > 0.1:
		look_at(look_target, Vector3.UP)

func _build_character() -> void:
	var uniform := StandardMaterial3D.new()
	uniform.albedo_color = Color(0.19, 0.27, 0.28)
	uniform.roughness = 0.92
	var vest := StandardMaterial3D.new()
	vest.albedo_color = Color(0.38, 0.34, 0.25)
	vest.roughness = 0.95
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.48, 0.36, 0.28)
	skin.roughness = 0.9
	var pack := StandardMaterial3D.new()
	pack.albedo_color = Color(0.12, 0.16, 0.16)
	pack.roughness = 1.0

	body_mesh = _add_capsule("Uniform", 0.34, 1.15, Vector3(0.0, 0.95, 0.0), uniform)
	_add_box("Field vest", Vector3(0.0, 1.0, -0.20), Vector3(0.62, 0.55, 0.22), vest)
	_add_box("Field pack", Vector3(0.0, 1.08, 0.27), Vector3(0.42, 0.58, 0.22), pack)
	head_mesh = _add_sphere("Head", 0.23, Vector3(0.0, 1.72, 0.0), skin)
	_add_box("Shoulder marker", Vector3(0.34, 1.22, -0.02), Vector3(0.12, 0.12, 0.12), vest)
	nameplate = Label3D.new()
	nameplate.name = "SquadNameplate"
	nameplate.text = "ELIAS ROOK  /  COMMS"
	nameplate.position = Vector3(0.0, 2.25, 0.0)
	nameplate.font_size = 24
	nameplate.modulate = Color(0.72, 0.86, 0.88)
	nameplate.outline_size = 6
	nameplate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(nameplate)

func _add_capsule(node_name: String, radius: float, height: float, at: Vector3, material: Material) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var capsule := CapsuleMesh.new()
	capsule.radius = radius
	capsule.height = height
	mesh_instance.mesh = capsule
	mesh_instance.position = at
	mesh_instance.material_override = material
	add_child(mesh_instance)
	return mesh_instance

func _add_sphere(node_name: String, radius: float, at: Vector3, material: Material) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	mesh_instance.mesh = sphere
	mesh_instance.position = at
	mesh_instance.material_override = material
	add_child(mesh_instance)
	return mesh_instance

func _add_box(node_name: String, at: Vector3, dimensions: Vector3, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var box := BoxMesh.new()
	box.size = dimensions
	mesh_instance.mesh = box
	mesh_instance.position = at
	mesh_instance.material_override = material
	add_child(mesh_instance)

func _get_obstacle_avoidance(desired_position: Vector3) -> Vector3:
	var origin := global_position + Vector3.UP * 1.0
	var target := desired_position + Vector3.UP * 1.0
	if origin.distance_to(target) < 0.8:
		return Vector3.ZERO
	var query := PhysicsRayQueryParameters3D.create(origin, target)
	query.collision_mask = 1
	if get_world_3d().direct_space_state.intersect_ray(query).is_empty():
		return Vector3.ZERO
	var side := (target - origin).cross(Vector3.UP).normalized()
	if side.length_squared() < 0.01:
		return Vector3.ZERO
	var left_query := PhysicsRayQueryParameters3D.create(origin, origin + side * 1.8 + Vector3.UP)
	left_query.collision_mask = 1
	var right_query := PhysicsRayQueryParameters3D.create(origin, origin - side * 1.8 + Vector3.UP)
	right_query.collision_mask = 1
	var left_blocked := not get_world_3d().direct_space_state.intersect_ray(left_query).is_empty()
	var right_blocked := not get_world_3d().direct_space_state.intersect_ray(right_query).is_empty()
	if left_blocked and right_blocked:
		return Vector3.ZERO
	if left_blocked:
		return -side * 1.15
	if right_blocked:
		return side * 1.15
	return side * 1.15
