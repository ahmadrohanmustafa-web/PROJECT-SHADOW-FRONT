#!/usr/bin/env python3
"""Generate a lightweight humanoid rig and generic locomotion clips from the uploaded glTF."""
import argparse
import json
import math
import os
import struct
import sys

import bpy
from mathutils import Matrix, Vector


def parse_args():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--output", required=True)
    return parser.parse_args(argv)


def deselect_all():
    for obj in bpy.context.selected_objects:
        obj.select_set(False)


def apply_world_transforms(meshes):
    for obj in meshes:
        obj.data.transform(obj.matrix_world.copy())
        obj.matrix_world = Matrix.Identity(4)


def bounds_for(meshes):
    points = [v.co.copy() for obj in meshes for v in obj.data.vertices]
    if not points:
        raise RuntimeError("The source glTF contains no mesh vertices.")
    mins = [min(p[i] for p in points) for i in range(3)]
    maxs = [max(p[i] for p in points) for i in range(3)]
    return mins, maxs


def orient_and_normalize(meshes):
    mins, maxs = bounds_for(meshes)
    extents = [maxs[i] - mins[i] for i in range(3)]
    up_axis = max(range(3), key=lambda i: extents[i])
    if up_axis == 0:
        rotation = Matrix.Rotation(math.pi / 2.0, 4, "Y")
    elif up_axis == 1:
        rotation = Matrix.Rotation(math.pi / 2.0, 4, "X")
    else:
        rotation = Matrix.Identity(4)
    if up_axis != 2:
        for obj in meshes:
            obj.data.transform(rotation)

    mins, maxs = bounds_for(meshes)
    height = maxs[2] - mins[2]
    if height <= 0.01:
        raise RuntimeError("Could not identify a usable character height.")
    scale = 1.8 / height
    offset = Vector(((mins[0] + maxs[0]) * 0.5, (mins[1] + maxs[1]) * 0.5, mins[2]))
    for obj in meshes:
        for vertex in obj.data.vertices:
            vertex.co = (vertex.co - offset) * scale
        obj.data.update()
    mins, maxs = bounds_for(meshes)
    return max(0.35, maxs[0] - mins[0]), max(0.25, maxs[1] - mins[1])


def join_meshes(meshes):
    deselect_all()
    for obj in meshes:
        obj.select_set(True)
    active = meshes[0]
    bpy.context.view_layer.objects.active = active
    bpy.ops.object.join()
    active.name = "MainCharacterMesh"
    active.data.name = "MainCharacterGeometry"
    active.location = (0.0, 0.0, 0.0)
    active.rotation_euler = (0.0, 0.0, 0.0)
    active.scale = (1.0, 1.0, 1.0)
    return active


def add_bone(edit_bones, name, head, tail, parent=None):
    bone = edit_bones.new(name)
    bone.head = Vector(head)
    bone.tail = Vector(tail)
    if parent:
        bone.parent = edit_bones[parent]
    return bone


def build_armature(width, depth):
    bpy.ops.object.armature_add(enter_editmode=True, location=(0.0, 0.0, 0.0))
    armature = bpy.context.object
    armature.name = "MainCharacterRig"
    armature.data.name = "MainCharacterSkeleton"
    edit_bones = armature.data.edit_bones
    for bone in list(edit_bones):
        edit_bones.remove(bone)

    h = 1.8
    shoulder = max(0.12, width * 0.23)
    elbow = max(0.17, width * 0.34)
    wrist = max(0.20, width * 0.42)
    hip = max(0.065, width * 0.105)

    add_bone(edit_bones, "root", (0, 0, 0.02), (0, 0, 0.14))
    add_bone(edit_bones, "pelvis", (0, 0, 0.43*h), (0, 0, 0.55*h), "root")
    add_bone(edit_bones, "spine", (0, 0, 0.52*h), (0, 0, 0.68*h), "pelvis")
    add_bone(edit_bones, "chest", (0, 0, 0.66*h), (0, 0, 0.79*h), "spine")
    add_bone(edit_bones, "neck", (0, 0, 0.78*h), (0, 0, 0.86*h), "chest")
    add_bone(edit_bones, "head", (0, 0, 0.84*h), (0, 0, 0.97*h), "neck")

    for side, sign in (("L", 1.0), ("R", -1.0)):
        add_bone(edit_bones, "upper_arm." + side,
                 (sign*shoulder, 0, 0.77*h), (sign*elbow, 0, 0.68*h), "chest")
        add_bone(edit_bones, "forearm." + side,
                 (sign*elbow, 0, 0.68*h), (sign*wrist, 0, 0.60*h), "upper_arm." + side)
        add_bone(edit_bones, "hand." + side,
                 (sign*wrist, 0, 0.60*h), (sign*(wrist + 0.055), 0, 0.585*h), "forearm." + side)
        add_bone(edit_bones, "thigh." + side,
                 (sign*hip, 0, 0.49*h), (sign*hip*1.08, 0, 0.27*h), "pelvis")
        add_bone(edit_bones, "shin." + side,
                 (sign*hip*1.08, 0, 0.27*h), (sign*hip*1.05, 0, 0.055*h), "thigh." + side)
        add_bone(edit_bones, "foot." + side,
                 (sign*hip*1.05, 0, 0.055*h),
                 (sign*hip*1.05, -max(0.08, depth*0.28), 0.035*h), "shin." + side)

    bpy.ops.object.mode_set(mode="OBJECT")
    armature.show_in_front = True
    armature.data.display_type = "STICK"
    return armature


def bind_mesh(mesh, armature):
    # Deterministic weights avoid heat-weight failures on disconnected equipment islands.
    deselect_all()
    for modifier in list(mesh.modifiers):
        if modifier.type == "ARMATURE":
            mesh.modifiers.remove(modifier)
    for group in list(mesh.vertex_groups):
        mesh.vertex_groups.remove(group)

    deform_bones = [bone for bone in armature.data.bones if bone.use_deform]
    if not deform_bones:
        raise RuntimeError("Generated armature contains no deform bones.")
    groups = {bone.name: mesh.vertex_groups.new(name=bone.name) for bone in deform_bones}
    segments = []
    for bone in deform_bones:
        head, tail = bone.head_local.copy(), bone.tail_local.copy()
        direction = tail - head
        segments.append((bone.name, head, direction, max(direction.length_squared, 1e-8)))

    for vertex in mesh.data.vertices:
        point = vertex.co
        distances = []
        for name, head, direction, length_sq in segments:
            t = max(0.0, min(1.0, (point - head).dot(direction) / length_sq))
            closest = head + direction * t
            distances.append(((point - closest).length_squared, name))
        distances.sort(key=lambda item: item[0])
        nearest = distances[:2]
        if len(nearest) == 1 or nearest[0][0] < 1e-10:
            groups[nearest[0][1]].add([vertex.index], 1.0, "REPLACE")
        else:
            inverse = [1.0 / max(distance, 1e-8) for distance, _ in nearest]
            total = sum(inverse)
            for (_, name), weight in zip(nearest, inverse):
                groups[name].add([vertex.index], weight / total, "REPLACE")

    mesh.parent = armature
    modifier = mesh.modifiers.new("CharacterArmature", "ARMATURE")
    modifier.object = armature
    modifier.use_vertex_groups = True
    mesh.data.update()
    return "deterministic two-bone weights"


def set_pose(armature, rotations):
    for pose_bone in armature.pose.bones:
        pose_bone.rotation_mode = "XYZ"
        pose_bone.rotation_euler = (0.0, 0.0, 0.0)
    for name, rotation in rotations.items():
        if armature.pose.bones.get(name):
            armature.pose.bones[name].rotation_euler = rotation


def make_action(armature, name, frame_poses, frame_end):
    if armature.animation_data is None:
        armature.animation_data_create()
    action = bpy.data.actions.new(name=name)
    action.use_fake_user = True
    armature.animation_data.action = action
    scene = bpy.context.scene
    scene.frame_start = 1
    scene.frame_end = frame_end
    for frame, rotations in frame_poses:
        scene.frame_set(frame)
        set_pose(armature, rotations)
        for pose_bone in armature.pose.bones:
            pose_bone.keyframe_insert(data_path="rotation_euler", frame=frame, group=pose_bone.name)
    # Smooth, repeatable locomotion curves. The final key duplicates the first
    # pose at the cycle boundary so the loop does not snap.
    for fcurve in getattr(action, "fcurves", []):
        for key in fcurve.keyframe_points:
            key.interpolation = "BEZIER"
            key.handle_left_type = "AUTO_CLAMPED"
            key.handle_right_type = "AUTO_CLAMPED"
    return action


def create_locomotion_actions(armature):
    make_action(armature, "Idle", [
        (1, {"chest": (0.008, 0.0, 0.0), "head": (0.0, 0.0, 0.0)}),
        (16, {"chest": (-0.012, 0.0, 0.0), "head": (0.018, 0.0, 0.0)}),
        (31, {"chest": (0.008, 0.0, 0.0), "head": (0.0, 0.0, 0.0)}),
    ], 30)

    walk = []
    for frame in (1, 7, 13, 19, 25):
        phase = ((frame - 1) / 24.0) * math.tau
        swing = math.sin(phase) * 0.34
        knee_l = max(0.0, math.sin(phase + 0.55)) * 0.20
        knee_r = max(0.0, math.sin(phase + math.pi + 0.55)) * 0.20
        walk.append((frame, {
            "thigh.L": (swing, 0.0, 0.0), "thigh.R": (-swing, 0.0, 0.0),
            "shin.L": (-knee_l, 0.0, 0.0), "shin.R": (-knee_r, 0.0, 0.0),
            "upper_arm.L": (-swing*0.72, 0.0, 0.0),
            "upper_arm.R": (swing*0.72, 0.0, 0.0),
            "forearm.L": (0.08, 0.0, 0.0), "forearm.R": (0.08, 0.0, 0.0),
            "chest": (0.0, 0.0, math.sin(phase)*0.018),
        }))
    make_action(armature, "Walk", walk, 24)

    run = []
    for frame in (1, 5, 10, 14, 19):
        phase = ((frame - 1) / 18.0) * math.tau
        swing = math.sin(phase) * 0.58
        knee_l = max(0.0, math.sin(phase + 0.7)) * 0.48
        knee_r = max(0.0, math.sin(phase + math.pi + 0.7)) * 0.48
        run.append((frame, {
            "thigh.L": (swing, 0.0, 0.0), "thigh.R": (-swing, 0.0, 0.0),
            "shin.L": (-knee_l, 0.0, 0.0), "shin.R": (-knee_r, 0.0, 0.0),
            "upper_arm.L": (-swing*0.85, 0.0, 0.0),
            "upper_arm.R": (swing*0.85, 0.0, 0.0),
            "forearm.L": (0.22, 0.0, 0.0), "forearm.R": (0.22, 0.0, 0.0),
            "chest": (0.035, 0.0, math.sin(phase)*0.03),
        }))
    make_action(armature, "Run", run, 18)


def verify_glb(path):
    with open(path, "rb") as handle:
        data = handle.read()
    if len(data) < 20 or data[:4] != b"glTF":
        raise RuntimeError("Blender did not produce a valid GLB file.")
    json_length = struct.unpack_from("<I", data, 12)[0]
    if data[16:20] != b"JSON":
        raise RuntimeError("GLB JSON chunk is missing.")
    document = json.loads(data[20:20+json_length].decode("utf-8").rstrip("\x00"))
    if not document.get("skins"):
        raise RuntimeError("Rig verification failed: exported GLB has no skin.")
    names = {item.get("name", "") for item in document.get("animations", [])}
    required = {"Idle", "Walk", "Run"}
    if not required.issubset(names):
        raise RuntimeError("Animation verification failed; found clips: " + repr(sorted(names)))
    print("MAIN CHARACTER RIG VERIFIED")
    print("Skins:", len(document["skins"]), "| Clips:", sorted(names), "| Bytes:", len(data))


def main():
    args = parse_args()
    source, output = os.path.abspath(args.input), os.path.abspath(args.output)
    os.makedirs(os.path.dirname(output), exist_ok=True)
    if not os.path.isfile(source):
        raise FileNotFoundError(source)

    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=source)
    meshes = [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]
    if not meshes:
        raise RuntimeError("No mesh objects were imported from the source character.")

    apply_world_transforms(meshes)
    width, depth = orient_and_normalize(meshes)
    mesh = join_meshes(meshes)
    armature = build_armature(width, depth)
    binding_mode = bind_mesh(mesh, armature)
    create_locomotion_actions(armature)

    deselect_all()
    mesh.select_set(True)
    armature.select_set(True)
    bpy.context.view_layer.objects.active = armature
    props = bpy.ops.export_scene.gltf.get_rna_type().properties
    export_args = {
        "filepath": output,
        "export_format": "GLB",
        "export_animations": True,
        "export_skins": True,
        "export_apply": True,
    }
    if "export_animation_mode" in props:
        export_args["export_animation_mode"] = "ACTIONS"
    if "export_force_sampling" in props:
        export_args["export_force_sampling"] = True
    bpy.ops.export_scene.gltf(**export_args)
    verify_glb(output)
    print("Binding mode:", binding_mode)
    print("Source: Solider by FoFLaFe, CC-BY-4.0")


if __name__ == "__main__":
    main()
