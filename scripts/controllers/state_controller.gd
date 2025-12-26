class_name StateController
extends Node

@export var player : PlayerController
@export var movement_controller : MovementController
@export var camera_effects_controller : CameraEffectsController

enum PlayerState {AIRBORN, LANDING, GROUNDED}

var current_state : PlayerState
var is_crouching := false
var is_walking := false

var was_on_floor : bool = false
var pre_move_velocity : Vector3

signal landed
signal landed_loud
signal landed_soft

## This could be better if we instead just connect the state to signals that are
## emitted from other controllers
func detect_current_state():
	pre_move_velocity = player.velocity
	
	is_crouching = Input.is_action_pressed("crouch")
	is_walking = Input.is_action_pressed("walk")
	
	var on_floor = player.is_on_floor()
	
	if !on_floor:
		#current_state = 'airborn'
		current_state = PlayerState.AIRBORN
	elif on_floor and !was_on_floor:
		#current_state = 'landing'
		current_state = PlayerState.LANDING
		on_landing(movement_controller.pre_move_velocity)
	else:
		#current_state = 'grounded'
		current_state = PlayerState.GROUNDED
	
	was_on_floor = on_floor
	
func on_landing(impact_velocity: Vector3):
	var impact = abs(impact_velocity.y)
	if (impact > 15):
		var max_fall_speed := 30.0
		var strength: float = clamp(impact / max_fall_speed, 0.0, 1.0)
		camera_effects_controller.shake(strength)
	
	if impact > 20:
		landed_loud.emit()
	elif impact > 8:
		landed_soft.emit()

	landed.emit()

func _physics_process(_delta: float) -> void:
	detect_current_state()
