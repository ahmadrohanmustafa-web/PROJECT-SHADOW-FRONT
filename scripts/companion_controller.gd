extends Node3D
class_name ShadowFrontCompanion

## Lightweight Elias Rook character with a procedural low-cost rig.
## Animation is built from a few primitive meshes; no imported skeleton or
## animation player is required, keeping the prototype friendly to older GPUs.

@export var follow_speed: float = 3.6
@export var follow_distance: float = 2.4
@export var catch_up_distance: float = 8.0

var follow_target: Node3D
var dialogue_index: int = 0
var nameplate: Label3D
var torso_pivot: Node3D
var head_pivot: Node3D
var left_arm_pivot: Node3D
var right_arm_pivot: Node3D
var left_leg_pivot: Node3D
var right_leg_pivot: Node3D
var animation_time: float = 0.0
var previous_position: Vector3
var movement_blend: float = 0.0

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
	previous_position = global_position
	_build_character()

func _process(delta: float) -> void:
	animation_time += delta
	if is_instance_valid(follow_target):
		_follow_player(delta)
	_animate_character(delta)

func _follow_player(delta: float) -> void:
	var behind_target := follow_target.global_transform.basis * Vector3(1.25, 0.0, 2.0)
	var desired_position := follow_target.global_position + behind_target
	desired_position.y = 0.0
	desired_position += _get_obstacle_avoidance(desired_position)
	var distance := global_position.distance_to(desired_position)
	if distance > follow_distance:
		var speed_scale := 1.35 if distance > catch_up_distance else 1.0
		global_position = global_position.move_toward(desired_position, follow_speed * speed_scale * delta)
	var look_target := follow_target.global_position
	look_target.y = global_position.y
	if global_position.distance_to(look_target) > 0.1:
		look_at(look_target, Vector3.UP)

func _build_character() -> void:
	var uniform := _material(Color(0.16, 0.22, 0.23))
	var vest := _material(Color(0.39, 0.34, 0.25))
	var skin := _material(Color(0.48, 0.36, 0.28))
	var pack := _material(Color(0.09, 0.13, 0.14))
	var dark := _material(Color(0.055, 0.075, 0.08))
	var trim := _material(Color(0.62, 0.58, 0.43))

	torso_pivot = Node3D.new()
	torso_pivot.name = "TorsoRig"
	torso_pivot.position.y = 0.95
	add_child(torso_pivot)
	_add_capsule(torso_pivot, "UniformBody", 0.34, 1.05, Vector3(0.0, 0.10, 0.0), uniform)
	_add_box(torso_pivot, "FieldVest", Vector3(0.0, 0.08, -0.205), Vector3(0.62, 0.55, 0.20), vest)
	_add_box(torso_pivot, "VestFrontPanel", Vector3(0.0, 0.08, -0.316), Vector3(0.38, 0.30, 0.025), trim)
	_add_box(torso_pivot, "FieldPack", Vector3(0.0, 0.12, 0.27), Vector3(0.43, 0.62, 0.23), pack)
	_add_box(torso_pivot, "Radio", Vector3(0.27, 0.34, -0.17), Vector3(0.13, 0.22, 0.10), dark)
	_add_box(torso_pivot, "ShoulderMarker", Vector3(0.34, 0.27, -0.02), Vector3(0.13, 0.13, 0.13), trim)

	head_pivot = Node3D.new()
	head_pivot.name = "HeadRig"
	head_pivot.position = Vector3(0.0, 1.72, 0.0)
	add_child(head_pivot)
	_add_sphere(head_pivot, "Head", 0.225, Vector3.ZERO, skin)
	_add_sphere(head_pivot, "Hair", 0.232, Vector3(0.0, 0.105, 0.025), dark)
	_add_box(head_pivot, "CommsEarpiece", Vector3(0.205, 0.0, 0.0), Vector3(0.07, 0.13, 0.10), trim)
	_add_box(head_pivot, "MicBoom", Vector3(0.12, -0.12, -0.17), Vector3(0.025, 0.025, 0.15), dark)

	left_arm_pivot = _create_limb_pivot("LeftArmRig", Vector3(-0.39, 1.34, 0.0), 0.14, 0.78, uniform)
	right_arm_pivot = _create_limb_pivot("RightArmRig", Vector3(0.39, 1.34, 0.0), 0.14, 0.78, uniform)
	left_leg_pivot = _create_limb_pivot("LeftLegRig", Vector3(-0.19, 0.58, 0.0), 0.155, 0.82, dark)
	right_leg_pivot = _create_limb_pivot("RightLegRig", Vector3(0.19, 0.58, 0.0), 0.155, 0.82, dark)

	_add_box(self, "LeftKneePad", Vector3(-0.19, 0.40, -0.14), Vector3(0.22, 0.20, 0.08), vest)
	_add_box(self, "RightKneePad", Vector3(0.19, 0.40, -0.14), Vector3(0.22, 0.20, 0.08), vest)

	nameplate = Label3D.new()
	nameplate.name = "SquadNameplate"
	nameplate.text = "ELIAS ROOK  /  COMMS"
	nameplate.position = Vector3(0.0, 2.35, 0.0)
	nameplate.font_size = 24
	nameplate.modulate = Color(0.72, 0.86, 0.88)
	nameplate.outline_size = 6
	nameplate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(nameplate)

func _create_limb_pivot(node_name: String, at: Vector3, radius: float, height: float, material: Material) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = node_name
	pivot.position = at
	add_child(pivot)
	_add_capsule(pivot, node_name + "Mesh", radius, height, Vector3(0.0, -height * 0.43, 0.0), material)
	return pivot

func _animate_character(delta: float) -> void:
	var distance_moved := global_position.distance_to(previous_position)
	previous_position = global_position
	var target_blend := clampf(distance_moved / maxf(delta * follow_speed, 0.001), 0.0, 1.0)
	movement_blend = move_toward(movement_blend, target_blend, delta * 5.0)

	var gait := animation_time * 7.5
	var swing := sin(gait) * movement_blend
	var idle := sin(animation_time * 1.7)
	if is_instance_valid(left_leg_pivot):
		left_leg_pivot.rotation.x = swing * 0.52
		right_leg_pivot.rotation.x = -swing * 0.52
		left_arm_pivot.rotation.x = -swing * 0.38 - 0.08
		right_arm_pivot.rotation.x = swing * 0.38 - 0.08
		torso_pivot.position.y = 0.95 + absf(sin(gait)) * 0.035 * movement_blend + idle * 0.012
		torso_pivot.rotation.z = sin(animation_time * 1.1) * 0.012
		head_pivot.rotation.x = sin(animation_time * 1.3) * 0.025
		head_pivot.rotation.y = sin(animation_time * 0.55) * 0.045

func _material(tint: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.94
	return material

func _add_capsule(parent: Node3D, node_name: String, radius: float, height: float, at: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	instance.mesh = mesh
	instance.position = at
	instance.material_override = material
	parent.add_child(instance)
	return instance

func _add_sphere(parent: Node3D, node_name: String, radius: float, at: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	instance.mesh = mesh
	instance.position = at
	instance.material_override = material
	parent.add_child(instance)
	return instance

func _add_box(parent: Node3D, node_name: String, at: Vector3, dimensions: Vector3, material: Material) -> void:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	instance.mesh = mesh
	instance.position = at
	instance.material_override = material
	parent.add_child(instance)

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
