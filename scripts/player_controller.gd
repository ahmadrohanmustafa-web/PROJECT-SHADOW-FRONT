extends CharacterBody3D
class_name ShadowFrontPlayer

## First playable controller. All movement values are prototype tuning,
## not a representation of real-world movement.

@export var walk_speed: float = 4.5
@export var sprint_speed: float = 6.5
@export var crouch_speed: float = 2.3
@export var ground_acceleration: float = 18.0
@export var air_acceleration: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.0018
@export var standing_fov: float = 75.0
@export var sprint_fov: float = 80.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var character_visual: Node3D = $CharacterVisual

var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))
var is_crouching: bool = false
var crouch_toggled: bool = false
var mouse_captured: bool = true
var invert_mouse_y: bool = false
var standing_capsule_height: float = 1.8
var crouching_capsule_height: float = 1.2
var standing_head_height: float = 1.55
var crouching_head_height: float = 1.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_captured = true
	camera.fov = standing_fov

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and mouse_captured:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(event.relative.y * mouse_sensitivity if invert_mouse_y else -event.relative.y * mouse_sensitivity)
		head.rotation.x = clampf(head.rotation.x, deg_to_rad(-85.0), deg_to_rad(85.0))

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_toggle_mouse_capture()
		elif event.keycode == KEY_C:
			crouch_toggled = not crouch_toggled
			_set_crouching(crouch_toggled or Input.is_key_pressed(KEY_CTRL))

	if event is InputEventMouseButton and event.pressed and not mouse_captured:
		_toggle_mouse_capture()

func _physics_process(delta: float) -> void:
	_set_crouching(crouch_toggled or Input.is_key_pressed(KEY_CTRL))

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_crouching:
		velocity.y = jump_velocity

	var input_vector := Vector2.ZERO
	if Input.is_key_pressed(KEY_A):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_vector.x += 1.0
	if Input.is_key_pressed(KEY_W):
		input_vector.y += 1.0
	if Input.is_key_pressed(KEY_S):
		input_vector.y -= 1.0
	input_vector = input_vector.normalized()

	var move_direction := (global_transform.basis * Vector3(input_vector.x, 0.0, -input_vector.y)).normalized()
	var target_speed := walk_speed
	if is_crouching:
		target_speed = crouch_speed
	elif Input.is_key_pressed(KEY_SHIFT):
		target_speed = sprint_speed

	var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
	var acceleration := ground_acceleration if is_on_floor() else air_acceleration
	var target_velocity := move_direction * target_speed
	horizontal_velocity = horizontal_velocity.move_toward(target_velocity, acceleration * delta)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

	camera.fov = move_toward(camera.fov, sprint_fov if target_speed == sprint_speed and input_vector.length() > 0.0 else standing_fov, 30.0 * delta)
	move_and_slide()
	character_visual.call("update_motion", Vector2(velocity.x, velocity.z).length(), is_on_floor())

func _set_crouching(enabled: bool) -> void:
	if is_crouching == enabled:
		return
	is_crouching = enabled
	var capsule := collision_shape.shape as CapsuleShape3D
	if capsule == null:
		return
	capsule.height = crouching_capsule_height if is_crouching else standing_capsule_height
	collision_shape.position.y = capsule.height * 0.5
	head.position.y = crouching_head_height if is_crouching else standing_head_height

func _toggle_mouse_capture() -> void:
	mouse_captured = not mouse_captured
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if mouse_captured else Input.MOUSE_MODE_VISIBLE
