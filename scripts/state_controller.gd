class_name StateController
extends Node

@export var player : PlayerController
@export var movement_controller : MovementController
@export var camera_effects_controller : CameraEffectsController

var current_state
var is_crouching
var is_walking

var was_on_floor : bool = false
var pre_move_velocity : Vector3

signal landed

## This could be better if we instead just connect the state to signals that are
## emitted from other controllers
func detect_current_state():
	pre_move_velocity = player.velocity
	
	is_crouching = Input.is_action_pressed("crouch")
	is_walking = Input.is_action_pressed("walk")
	
	var on_floor = player.is_on_floor()
	
	if !on_floor:
		current_state = 'airborn'
	elif on_floor and !was_on_floor:
		current_state = 'landing'
		on_landing(movement_controller.pre_move_velocity)
	else:
		current_state = 'grounded'
	
	was_on_floor = on_floor
	
func on_landing(impact_velocity: Vector3):
	if (abs(impact_velocity.y) > 15):
		var max_fall_speed := 30.0
		var strength: float = clamp(abs(impact_velocity.y) / max_fall_speed, 0.0, 1.0)
		camera_effects_controller.shake(strength)
	landed.emit(abs(impact_velocity.y) > 20)

func _physics_process(_delta: float) -> void:
	detect_current_state()
