class_name AirMovement extends BaseMovement

# Air movement settings. Need to tweak these to get the feeling dialed in.
var air_cap := 0.85 # Can surf steeper ramps if this is higher, makes it easier to stick and bhop
var air_accel := 800.0
var air_move_speed := 500.0

var player_gravity = Vector3(0, -40.0, 0)

func update(delta: float) -> void:
	apply_air_acceleration(delta)
	apply_gravity(delta)

func apply_air_acceleration(delta):
	# Classic battle tested & fan favorite source/quake air movement recipe.
	# CSS players gonna feel their gamer instincts kick in with this one
	var cur_speed_in_wish_dir = player.velocity.dot(movement_controller.wish_dir)
	# Wish speed (if wish_dir > 0 length) capped to air_cap
	var capped_speed = min((air_move_speed * movement_controller.wish_dir).length(), air_cap)
	# How much to get to the speed the player wishes (in the new dir)
	# Notice this allows for infinite speed. If wish_dir is perpendicular, we always need to add velocity
	# no matter how fast we're going. This is what allows for things like bhop in CSS & Quake.
	# Also happens to just give some very nice feeling movement & responsiveness when in the air.
	var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = air_accel * air_move_speed * delta # Usually is adding this one.
		accel_speed = min(accel_speed, add_speed_till_cap) # Works ok without this but sticking to the recipe
		player.velocity += accel_speed * movement_controller.wish_dir

func apply_gravity(delta: float):
	player.velocity += player_gravity * delta
