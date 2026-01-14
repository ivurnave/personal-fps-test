class_name CameraController
extends Node3D

@export_category("References")
@export var movement_controller : MovementController

@export_category("Camera Settings")
@export var tilt_lower_limit = -90
@export var tilt_upper_limit = 90
@export var shake_decay_speed: float = 10.0

var _rotation : Vector3

func update_camera_for_mouse_movement(input: Vector2) -> void:
	_rotation.x += input.y
	_rotation.y += input.x
	_rotation.x = clamp(_rotation.x, deg_to_rad(tilt_lower_limit), deg_to_rad(tilt_upper_limit))
	
	# separate player and camera rotations
	var _camera_rotation = Vector3(_rotation.x, 0, 0)
	var _player_rotation = Vector3(0, _rotation.y, 0)
	
	# apply rotation to camera controller (this node)
	transform.basis = Basis.from_euler(_camera_rotation)
	
	# apply rotation to player
	movement_controller.update_rotation(_player_rotation)
	
	rotation.z = 0 # prevent weird z-rotations
