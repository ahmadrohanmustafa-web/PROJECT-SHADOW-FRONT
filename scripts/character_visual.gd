extends Node3D
class_name ShadowFrontCharacterVisual

var animation_player: AnimationPlayer
var idle_clip: StringName
var walk_clip: StringName
var run_clip: StringName
var active_clip: StringName


func _ready() -> void:
	var players := find_children("*", "AnimationPlayer", true, false)
	if not players.is_empty():
		animation_player = players[0] as AnimationPlayer
		_resolve_clips()
		_play_clip(idle_clip)

	var meshes := find_children("*", "MeshInstance3D", true, false)
	for item in meshes:
		var mesh_instance := item as MeshInstance3D
		if mesh_instance:
			mesh_instance.layers = 1


func update_motion(horizontal_speed: float, grounded: bool) -> void:
	if not animation_player or not grounded:
		return
	var target := idle_clip
	if horizontal_speed > 3.7:
		target = run_clip
	elif horizontal_speed > 0.18:
		target = walk_clip
	_play_clip(target)


func _resolve_clips() -> void:
	idle_clip = _find_clip("idle")
	walk_clip = _find_clip("walk")
	run_clip = _find_clip("run")
	for clip_name in animation_player.get_animation_list():
		var clip := animation_player.get_animation(clip_name)
		if clip:
			clip.loop_mode = Animation.LOOP_LINEAR


func _find_clip(keyword: String) -> StringName:
	for clip_name in animation_player.get_animation_list():
		if String(clip_name).to_lower().contains(keyword):
			return StringName(clip_name)
	return StringName()


func _play_clip(clip_name: StringName) -> void:
	if clip_name.is_empty() or not animation_player:
		return
	if active_clip == clip_name and animation_player.is_playing():
		return
	active_clip = clip_name
	animation_player.play(clip_name, 0.16)
