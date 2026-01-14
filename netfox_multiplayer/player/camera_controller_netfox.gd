extends Node3D
class_name CameraControllerNetfox

@export_category("Camera Settings")
@export var tilt_lower_limit = -1.57
@export var tilt_upper_limit = 1.57

var player : PlayerControllerNetfox

func initialize(_player: PlayerControllerNetfox):
	player = _player

## Rotate the camera and the player
func update(look_angle: Vector2) -> void:
	_rotate_camera(look_angle)
	_rotate_player(look_angle)


func _rotate_camera(look_angle):
	rotate_object_local(Vector3(1, 0, 0), look_angle.y)
	rotation.x = clamp(rotation.x, tilt_lower_limit, tilt_upper_limit)
	rotation.z = 0
	rotation.y = 0

func _rotate_player(look_angle: Vector2) -> void:
	player.rotate_object_local(Vector3(0, 1, 0), look_angle.x)