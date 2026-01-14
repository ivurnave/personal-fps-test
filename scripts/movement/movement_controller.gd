class_name MovementController extends Node

#@export var inputs : InputSynchronizer
@export var inputs : InputSynchronizerRPC

enum MoveState {GROUND, AIR, WATER, LADDER, NOCLIP}

## Holds the current MoveState value of the player
var state : MoveState = MoveState.AIR

## This dictionary holds the different movement type handlers
var modes : Dictionary[MoveState, BaseMovement] = {}

## Holds reference to player controller
var player : PlayerController

## Get the user input direction relative to the player
var wish_dir : Vector3

## Holds reference to vector of user inputs (Y direction is always zero)
var input_dir: Vector3

## Cached velocity before we update it
var pre_move_velocity : Vector3

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
		mode.init(_player, self, inputs)

func detect_state():
	if !player.is_on_floor():
		state = MoveState.AIR
		return
	state = MoveState.GROUND

func update_rotation(rotation_direction: Vector3):
	player.global_transform.basis = Basis.from_euler(rotation_direction)

func get_wish_dir():
	return player.global_transform.basis * inputs.movement_input

func _force_update_is_on_floor():
	var old_velocity = player.velocity
	player.velocity = Vector3.ZERO
	player.move_and_slide()
	player.velocity = old_velocity

## Call this function from within the rollback tick
func update(delta):
	_force_update_is_on_floor()
	detect_state()
	input_dir = inputs.movement_input
	wish_dir = get_wish_dir()
	modes[state].update(delta)
	pre_move_velocity = player.velocity
	player.velocity *= NetworkTime.physics_factor
	player.move_and_slide()
	player.velocity /= NetworkTime.physics_factor


func _on_weapon_manager_weapon_equipped(weapon: WeaponResource) -> void:
	if player:
		player.ground_speed = weapon.max_movement_speed
		player.walk_speed = weapon.max_walk_speed
		player.crouch_speed = weapon.max_crouch_speed
