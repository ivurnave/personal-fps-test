class_name AnimationController
extends Node

@export var player : PlayerController
@export var animation_tree : AnimationTree

func processAnimationBasedOnState():
	# This is how we can change the speed of animations based on the speed of the player
	var normalized_horizontal_velocity = Vector2(player.velocity.x, -player.velocity.z) * (1 / player.ground_speed)
	animation_tree['parameters/Locomotion/blend_position'] = normalized_horizontal_velocity
