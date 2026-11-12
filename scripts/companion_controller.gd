extends Node3D
class_name ShadowFrontCompanion

## Squad companion using the uploaded, rigged Solider model.
## The player remains first-person; this character is a visible squad member.

const CHARACTER_SCENE: PackedScene = preload("res://assets/characters/player_character.glb")
const CHARACTER_VISUAL_SCRIPT = preload("res://scripts/character_visual.gd")

@export var follow_speed: float = 4.0
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
	var look_target := follow_target.global_position
	look_target.y = global_position.y
	if global_position.distance_to(look_target) > 0.1:
		look_at(look_target, Vector3.UP)
	if character_visual:
		var speed := global_position.distance_to(previous_position) / maxf(delta, 0.0001)
		character_visual.update_motion(speed, true)
	previous_position = global_position

func _build_character() -> void:
	var visual_root := Node3D.new()
	visual_root.name = "CharacterVisual"
	visual_root.set_script(CHARACTER_VISUAL_SCRIPT)
	add_child(visual_root)
	character_visual = visual_root as ShadowFrontCharacterVisual

	var soldier := CHARACTER_SCENE.instantiate() as Node3D
	soldier.name = "SoliderSquadModel"
	visual_root.add_child(soldier)

	nameplate = Label3D.new()
	nameplate.name = "SquadNameplate"
	nameplate.text = "ELIAS ROOK  /  COMMS"
	nameplate.position = Vector3(0.0, 2.15, 0.0)
	nameplate.font_size = 24
	nameplate.modulate = Color(0.72, 0.86, 0.88)
	nameplate.outline_size = 6
	nameplate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(nameplate)

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
