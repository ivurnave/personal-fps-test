class_name DecalEffectsSpawner
extends Node

@onready var decal_scene : PackedScene = load("res://scenes/weapons/bullet_decal_debug.tscn")

## Called via signals
func spawn_decal(position: Vector3, surface_normal: Vector3, collider: Object):
	if !position || !surface_normal:
		return
	var decal_instance = get_decal_instance_for_collision_surface(collider)
	var world = get_tree().get_root()
	var offset_from_face = 0.01
	world.add_child(decal_instance)
	var new_basis = Basis.looking_at(-surface_normal, Vector3.UP).scaled(decal_instance.scale)
	decal_instance.global_transform = Transform3D(
		new_basis,
		position + (surface_normal * offset_from_face)
	)

## In the future, make the collider map to a specific decal type
func get_decal_instance_for_collision_surface(_collider: Object):
	return decal_scene.instantiate()
