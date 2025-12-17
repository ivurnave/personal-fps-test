class_name CameraEffectsController
extends Node3D

## Max rotation to apply to the player when they fall
@export var max_fall_rotation := 0.25

## Rate at which the target rotation returns to (0,0,0)
@export var return_speed := 10.0

## Rate at which the current rotation lerps to the target rotation
@export var snappiness := 10.0 

# Recoil vectors
@export var recoil : Vector3

# Rotations
var current_rotation : Vector3
var target_rotation : Vector3

var current_roll_z := 0.0
var target_roll := 0.0

## Apply a rotational camera shake
func shake(amount: float):
	target_rotation.z = clamp(amount, 0, 1) * max_fall_rotation * sign(randf() - 0.5)

func _process(delta):
	# Lerp target rotation to (0,0,0) and lerp current rotation to target rotation
	target_rotation = lerp(target_rotation, Vector3.ZERO, return_speed * delta)
	current_rotation = lerp(current_rotation, target_rotation, snappiness * delta)
	
	# Set rotation
	rotation = current_rotation

## TODO: Use the weapon resource to determine how much recoil to apply
func _on_weapon_manager_weapon_fire(_weapon: WeaponResource) -> void:
	target_rotation += Vector3(recoil.x, randf_range(-recoil.y, recoil.y), randf_range(-recoil.z, recoil.z))
