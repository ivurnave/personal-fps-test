class_name MovementController extends Node

enum MoveState {GROUND, AIR, WATER, LADDER, NOCLIP}

## Holds the current MoveState value of the player
var state : MoveState = MoveState.AIR

## This dictionary holds the different movement type handlers
var modes = {}

## Holds reference to player controller
var player : PlayerController

## Get the user input direction relative to the player
var wish_dir : Vector3

## Holds reference to vector of user inputs (Y direction is always zero)
var input_dir: Vector3

func initialize(_player: PlayerController):
	player = _player
	modes = {
		MoveState.GROUND: GroundMovement.new(),
		MoveState.AIR: AirMovement.new(),
		#MoveState.WATER: WaterMovement.new(),
		#MoveState.LADDER: LadderMovement.new(),
		#MoveState.NOCLIP: NoclipMovement.new(),
	}
	for mode in modes.values():
		mode.init(_player, self)

func detect_state():
	if !player.is_on_floor():
		state = MoveState.AIR
		return
	state = MoveState.GROUND

func get_input_direction() -> Vector3:
	var input_dir_raw = Input.get_vector("move_left","move_right","move_forward","move_backward")
	return Vector3(input_dir_raw.x, 0, input_dir_raw.y)

func get_wish_dir():
	return player.global_transform.basis * get_input_direction()

## Call this function from within the physics process
func update(delta):
	detect_state()
	input_dir = get_input_direction()
	wish_dir = get_wish_dir()
	modes[state].update(delta)
	player.move_and_slide()
