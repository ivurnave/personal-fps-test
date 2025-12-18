class_name ViewModelMovement
extends Node3D

@export var player : PlayerController
@export var mouse_capture : MouseCaptureComponent
@export var max_rotation := 2.0
@export var max_rotation_offset := 1.0
@export var max_vertical_offset := 0.2
@export var rotation_smooth_speed := 10.0

@export var bob_frequency := 3.0
@export var bob_amplitude := Vector3(0.01, 0.01, 0.0)
@export var bob_smooth_speed := 10.0

var bob_time := 0.0
var bob_offset := Vector3.ZERO

var default_pos : Vector3
var default_rot : Vector3

var target_pos : Vector3
var target_rot : Vector3

var view_model_shake_amount := 0.1

func _ready():
	default_pos = position
	default_rot = rotation

func _physics_process(delta: float) -> void:
	apply_rotation_for_mouse_movement(mouse_capture._mouse_input)
	apply_offset_for_mouse_movement(mouse_capture._mouse_input)
	apply_offset_for_player_velocity()
	
	ease_back_to_default(delta)

func ease_back_to_default(delta: float):
	rotation = lerp(rotation, target_rot, rotation_smooth_speed * delta)
	position = lerp(position, target_pos, rotation_smooth_speed * delta)

func apply_rotation_for_mouse_movement(input: Vector2) -> void:
	var target_y := default_rot.y + input.x * max_rotation
	target_rot.y = target_y

func apply_offset_for_mouse_movement(input: Vector2) -> void:
	var target_offset_x := default_pos.x + input.x * max_rotation_offset
	target_pos.x = target_offset_x
	#position.x = lerp(position.x, target_offset_x, rotation_smooth_speed * delta)

func apply_offset_for_player_velocity() -> void:
	var target_offset_y := clampf(default_pos.y - (player.velocity.y / 300.0) * max_rotation_offset, -max_vertical_offset, max_vertical_offset)
	target_pos.y = target_offset_y

## TODO: Come back to this sometime
#func apply_view_model_bob(delta: float) -> void:
	#if not is_player_moving():
		## Smoothly return to rest when stopping
		#bob_offset = bob_offset.lerp(Vector3.ZERO, bob_smooth_speed * delta)
	#else:
		#var speed_factor := clampf(player.velocity.length() / player.ground_speed, 0.0, 1.0)
		#bob_time += delta * bob_frequency * speed_factor
		#var target_offset := Vector3(
			#sin(bob_time) * bob_amplitude.x,
			#abs(cos(bob_time)) * bob_amplitude.y,
			#0.0
		#)
		#bob_offset = bob_offset.lerp(target_offset, bob_smooth_speed * delta)
	#position = position + bob_offset

func is_player_moving() -> bool:
	return player.velocity.length_squared() > 0.01 && player.is_on_floor()

func _on_weapon_manager_weapon_fire(_recoil: Vector2) -> void:
	position.z += view_model_shake_amount
