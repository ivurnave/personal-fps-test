class_name ViewModelEffectsNetfox
extends Node3D

@export var inputs : PlayerInputsNetfox
@export var max_rotation := 2.0
@export var max_rotation_offset := 1.0
@export var max_vertical_offset := 0.2
@export var rotation_smooth_speed := 10.0

var player : PlayerControllerNetfox
var _default_pos : Vector3
var _default_rot : Vector3
var _target_pos : Vector3
var _target_rot : Vector3

func _ready():
	_default_pos = position
	_default_rot = rotation
	_target_pos = position
	_target_rot = rotation

func initialize(_player: PlayerControllerNetfox):
	player = _player

func update(delta: float):
	_apply_rotation_for_mouse_movement(inputs.look_angle)
	_apply_offset_for_mouse_movement(inputs.look_angle)
	_apply_offset_for_player_velocity()
	_ease_toward_target(delta)

func _ease_toward_target(delta: float):
	rotation = lerp(rotation, _target_rot, rotation_smooth_speed * delta)
	position = lerp(position, _target_pos, rotation_smooth_speed * delta)

func _apply_rotation_for_mouse_movement(input: Vector2) -> void:
	var target_y := _default_rot.y + input.x * max_rotation
	_target_rot.y = target_y

func _apply_offset_for_mouse_movement(input: Vector2) -> void:
	_target_pos.x = _default_pos.x + input.x * max_rotation_offset

func _apply_offset_for_player_velocity() -> void:
	_target_pos.y = clampf(_default_pos.y - (player.velocity.y / 300.0) * max_rotation_offset, -max_vertical_offset, max_vertical_offset)

# func is_player_moving() -> bool:
# 	return player.velocity.length_squared() > 0.01 && player.is_on_floor()
