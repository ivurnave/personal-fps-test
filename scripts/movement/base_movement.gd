@abstract
class_name BaseMovement extends Node

var player: PlayerController
var movement_controller: MovementController

## Sets reference to the player property
func init(_player: PlayerController, _movement_controller):
	player = _player
	movement_controller = _movement_controller

## Called from the player controller, updates the player's velocity
@abstract
func update(delta: float)
