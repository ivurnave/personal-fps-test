@abstract
class_name BaseMovement extends Node

var player: PlayerControllerNetfox
var movement_controller: MovementControllerNetfox
var inputs: PlayerInputsNetfox

func init(_player: PlayerControllerNetfox, _movement_controller: MovementControllerNetfox, _inputs: PlayerInputsNetfox):
	player = _player
	movement_controller = _movement_controller
	inputs = _inputs

## Called from the player controller, updates the player's velocity
@abstract
func update(delta: float)
