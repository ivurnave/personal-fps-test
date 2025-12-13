class_name CameraEffectsController
extends Node3D

@export var max_rotation := PI/16
@export var decay := 1.0

var current_roll := 0.0
var target_roll := 0.0

## Apply a rotational camera shake
func shake(amount: float):
	current_roll = clamp(amount, 0, 1) * max_rotation * sign(randf() - 0.5)

func _process(delta):
	current_roll = move_toward(current_roll, target_roll, decay * delta)
	rotation.z = current_roll
