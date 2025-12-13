class_name GroundMovement extends BaseMovement

# Ground movement settings
@export var walk_speed := 7.0
@export var sprint_speed := 8.5
#@export var max_sprint_speed := 10
@export var ground_accel := 11.0
@export var ground_decel := 7.0
@export var ground_friction := 3.5

func update(delta: float):
	apply_ground_friction(delta)
	apply_ground_acceleration(delta)
	apply_jump_velocity()

## Take the direction we are already going and reduce it by some amount
func apply_ground_friction(delta: float):
	var control = max(player.velocity.length(), ground_decel)
	var drop = control * ground_friction * delta
	var new_speed = max(player.velocity.length() - drop, 0.0)
	if player.velocity.length() > 0:
		new_speed /= player.velocity.length()
	player.velocity *= new_speed

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
	if Input.is_action_just_pressed("jump"):
		player.velocity.y = player.jump_speed

func get_move_speed() -> float:
	if player.is_crouching: return player.crouch_speed
	if player.is_walking: return player.walk_speed
	return player.ground_speed
