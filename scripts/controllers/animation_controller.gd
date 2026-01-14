extends Node
class_name AnimationController

func update_posture(player: PlayerController, delta: float):
	var current_height = player.collision_shape.shape.height
	if player.state_controller.is_crouching:
		current_height = max(
			current_height - (player.posture_change_speed * delta),
			player.crouch_height
		)
	else:
		current_height = min(
			current_height + (player.posture_change_speed * delta),
			player.stand_height
		)
	player.collision_shape.shape.height = current_height
