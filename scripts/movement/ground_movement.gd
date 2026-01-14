extends BaseMovement
class_name GroundMovement

# Ground movement settings
var ground_accel := 11.0
var ground_decel := 7.0
var ground_friction := 3.5

func update(delta: float):
	apply_ground_friction(delta)
	apply_ground_acceleration(delta)
	apply_jump_velocity()

## Take the direction we are already going and reduce it by some amount
func apply_ground_friction(delta: float):
	if movement_controller.wish_dir != Vector3.ZERO:
		return  # no friction while accelerating
	var speed = player.velocity.length()
	if speed == 0:
		return
	var control = max(speed, ground_decel)
	var drop = control * ground_friction * delta
	var new_speed = max(player.velocity.length() - drop, 0.0)
	player.velocity *= new_speed / speed

## Apply acceleration in the direction of the inputs according to the current direction of the player
func apply_ground_acceleration(delta: float):
	var cur_speed_in_wish_dir = player.velocity.dot(movement_controller.wish_dir)
	var add_speed_till_cap = get_move_speed() - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = ground_accel * delta * get_move_speed()
		accel_speed = min(accel_speed, add_speed_till_cap)
		player.velocity += accel_speed * movement_controller.wish_dir
	if player.velocity.length() > get_move_speed():
			player.velocity = player.velocity.normalized() * get_move_speed()

## Set upward velocity, transfering us to air state (probably)
func apply_jump_velocity():
	if inputs.jump_input:
		inputs.jump_input = false
		player.velocity.y = player.jump_speed

func get_move_speed() -> float:
	# if player.state_controller.is_crouching: return player.crouch_speed
	# if player.state_controller.is_walking: return player.walk_speed
	# return player.ground_speed
	# if movement_controller.inputs. == : return player.crouch_speed
	# if player.state_controller.is_walking: return player.walk_speed
	return player.ground_speed
