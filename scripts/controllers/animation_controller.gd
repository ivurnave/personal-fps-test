class_name AnimationController
extends Node

@export var player : PlayerController
@export var animation_tree : AnimationTree

func update_posture(delta: float):
	#var current_height: float = $CollisionShape3D.shape.height
	var current_height = player.collision_shape.shape.height
	if player.state_controller.is_crouching:
		player.current_height = max(
			player.current_height - (player.posture_change_speed * delta),
			player.crouch_height
		)
	else:
		player.current_height = min(
			player.current_height + (player.posture_change_speed * delta),
			player.stand_height
		)
	player.collision_shape.shape.height = current_height

func processAnimationBasedOnState():
	# This is how we can change the speed of animations based on the speed of the player
	var normalized_horizontal_velocity = Vector2(player.velocity.x, -player.velocity.z) * (1 / player.ground_speed)
	animation_tree['parameters/Locomotion/blend_position'] = normalized_horizontal_velocity
