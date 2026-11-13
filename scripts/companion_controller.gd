extends Node3D
class_name ShadowFrontCompanion

## Visible squad companion. The player remains first-person.

const CHARACTER_SCENE: PackedScene = preload("res://assets/characters/player_character.glb")
const CHARACTER_VISUAL_SCRIPT = preload("res://scripts/character_visual.gd")

@export var follow_speed: float = 2.2
@export var follow_distance: float = 2.4
@export var catch_up_distance: float = 6.5

var follow_target: Node3D
var dialogue_index: int = 0
var nameplate: Label3D
var character_visual: ShadowFrontCharacterVisual
var previous_position: Vector3
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
	previous_position = global_position

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

	global_position.y = 0.0

	var look_target := follow_target.global_position
	look_target.y = global_position.y
	if global_position.distance_to(look_target) > 0.1:
		look_at(look_target, Vector3.UP)

	if character_visual:
		var horizontal_delta := Vector2(
			global_position.x - previous_position.x,
			global_position.z - previous_position.z
		)
		var horizontal_speed := horizontal_delta.length() / maxf(delta, 0.0001)
		character_visual.update_motion(horizontal_speed, true)
	previous_position = global_position

func _build_character() -> void:
	# Build the full subtree before entering the scene tree so the visual script
	# can discover the GLB AnimationPlayer during its deferred initialization.
	var visual_root := Node3D.new()
	visual_root.name = "CharacterVisual"
	visual_root.set_script(CHARACTER_VISUAL_SCRIPT)

	var soldier := CHARACTER_SCENE.instantiate() as Node3D
	soldier.name = "SoliderSquadModel"
	_orient_soldier_from_mesh_geometry(soldier)
	# The Blender rig generator already normalizes the mesh to upright Z and
	# the glTF exporter converts Blender Z-up to Godot Y-up. Do NOT rotate it
	# again here: that applies a second quarter-turn and lays the soldier over.
	visual_root.add_child(soldier)
	add_child(visual_root)
	character_visual = visual_root as ShadowFrontCharacterVisual

	nameplate = Label3D.new()
	nameplate.name = "SquadNameplate"
	nameplate.text = "ELIAS ROOK  /  COMMS"
	nameplate.position = Vector3(0.0, 2.15, 0.0)
	nameplate.font_size = 24
	nameplate.modulate = Color(0.72, 0.86, 0.88)
	nameplate.outline_size = 6
	nameplate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(nameplate)

func _orient_soldier_from_mesh_geometry(soldier: Node3D) -> void:
	# Runtime safety net: inspect the imported mesh itself, not guessed source axes.
	# The dominant geometric body axis is aligned to Godot's Y-up direction.
	var points: Array[Vector3] = []
	var mesh_nodes := soldier.find_children("*", "MeshInstance3D", true, false)
	for node in mesh_nodes:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		for surface_index in range(mesh_instance.mesh.get_surface_count()):
			var arrays := mesh_instance.mesh.surface_get_arrays(surface_index)
			if arrays.is_empty() or arrays[Mesh.ARRAY_VERTEX] == null:
				continue
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			for vertex in vertices:
				points.append(mesh_instance.transform * vertex)
	if points.size() < 8:
		push_warning("Elias orientation check skipped: imported mesh vertices unavailable.")
		return

	var center := Vector3.ZERO
	for point in points:
		center += point
	center /= float(points.size())

	var covariance := [
		[0.0, 0.0, 0.0],
		[0.0, 0.0, 0.0],
		[0.0, 0.0, 0.0]
	]
	for point in points:
		var d: Vector3 = point - center
		covariance[0][0] += d.x * d.x
		covariance[0][1] += d.x * d.y
		covariance[0][2] += d.x * d.z
		covariance[1][0] += d.y * d.x
		covariance[1][1] += d.y * d.y
		covariance[1][2] += d.y * d.z
		covariance[2][0] += d.z * d.x
		covariance[2][1] += d.z * d.y
		covariance[2][2] += d.z * d.z

	var spreads := [covariance[0][0], covariance[1][1], covariance[2][2]]
	var seed := 0
	if spreads[1] > spreads[seed]:
		seed = 1
	if spreads[2] > spreads[seed]:
		seed = 2
	var axis := Vector3.ZERO
	axis[seed] = 1.0
	for iteration in range(48):
		var next_axis := Vector3(
			covariance[0][0] * axis.x + covariance[0][1] * axis.y + covariance[0][2] * axis.z,
			covariance[1][0] * axis.x + covariance[1][1] * axis.y + covariance[1][2] * axis.z,
			covariance[2][0] * axis.x + covariance[2][1] * axis.y + covariance[2][2] * axis.z
		)
		if next_axis.length_squared() < 0.00000001:
			push_warning("Elias orientation check failed: no dominant body axis.")
			return
		next_axis = next_axis.normalized()
		if (next_axis - axis).length() < 0.00001 or (next_axis + axis).length() < 0.00001:
			axis = next_axis
			break
		axis = next_axis

	var correction := Quaternion(axis.normalized(), Vector3.UP)
	# The imported soldier's forward axis is quarter-turned relative to Godot's
	# -Z forward convention. Apply a local yaw correction after standing him up.
	var face_forward := Quaternion(Vector3.UP, deg_to_rad(90.0))
	var combined_correction := face_forward * correction
	soldier.basis = Basis(combined_correction) * soldier.basis

	# Put the lowest transformed mesh point on the local ground plane.
	var lowest_y := INF
	for point in points:
		var corrected := combined_correction * point
		lowest_y = minf(lowest_y, corrected.y)
	soldier.position.y -= lowest_y
	print("Elias runtime upright correction; principal axis=", axis, " ground_offset=", lowest_y)

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
