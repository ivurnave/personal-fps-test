class_name CameraEffectsController
extends Node3D

## Max rotation to apply to the player when they fall
@export var max_fall_rotation := 0.25

## Rate at which the target rotation returns to (0,0,0)
@export var return_speed := 10.0

## Rate at which the current rotation lerps to the target rotation
@export var snappiness := 10.0 

# Rotations
var current_rotation : Vector3
var target_rotation : Vector3

# Positions
var current_position : Vector3
var target_position : Vector3

## Apply a rotational camera shake
func shake(amount: float):
	target_rotation.z = clamp(amount, 0, 1) * max_fall_rotation * sign(randf() - 0.5)

func _process(delta):
	# Lerp target rotation to (0,0,0) and lerp current rotation to target rotation
	target_rotation = lerp(target_rotation, Vector3.ZERO, return_speed * delta)
	current_rotation = lerp(current_rotation, target_rotation, snappiness * delta)
	
	target_position = lerp(target_position, Vector3.ZERO, return_speed * delta)
	current_position = lerp(current_position, target_position, snappiness * delta)
	
	# Set rotation
	rotation = current_rotation
	position = current_position

## Called via the weapon "fired" signal
func on_weapon_recoil(recoil: Vector2):
	add_recoil(-recoil.y, -recoil.x)
	add_screen_recoil(-0.2)

func add_screen_recoil(amount: float):
	target_position.z += amount

func add_recoil(pitch: float, yaw: float) -> void:
	target_rotation.x += pitch
	target_rotation.y += yaw
