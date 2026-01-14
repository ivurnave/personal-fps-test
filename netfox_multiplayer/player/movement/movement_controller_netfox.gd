class_name MovementControllerNetfox extends Node

@export var inputs : PlayerInputsNetfox

## Holds reference to player controller
var player : PlayerControllerNetfox

## Movement controls
@export var ground_speed := 6.0
@export var air_speed := 6.0
@export var jump_speed := 10.0
@export var walk_speed := 3.0
@export var crouch_speed := 2.5

enum MoveState {GROUND, AIR, WATER, LADDER, NOCLIP}
var movement_states : Dictionary[MoveState, BaseMovement] = {}
var current_state : MoveState
var wish_dir : Vector3

func initialize(_player: PlayerControllerNetfox):
	player = _player
	movement_states = {
		MoveState.GROUND: GroundMovement.new(),
		MoveState.AIR: AirMovement.new(),
	}
	for mode in movement_states.values():
		mode.init(_player, self, inputs)

## Call this function from within the rollback tick
func update(delta: float):
	_force_update_is_on_floor()
	wish_dir = _get_wish_dir()

	current_state = _detect_state()
	movement_states[current_state].update(delta)
	
	_network_safe_move_and_slide()

func _get_wish_dir():
	return player.global_transform.basis * inputs.movement_input

func _detect_state() -> MoveState:
	if !player.is_on_floor():
		return MoveState.AIR
	return MoveState.GROUND

func _network_safe_move_and_slide():
	player.velocity *= NetworkTime.physics_factor
	player.move_and_slide()
	player.velocity /= NetworkTime.physics_factor

func _force_update_is_on_floor():
	var old_velocity = player.velocity
	player.velocity = Vector3.ZERO
	player.move_and_slide()
	player.velocity = old_velocity
