class_name TactialFPSPlayerController extends CharacterBody3D

@export var debug := false

@export_subgroup("Movement Settings")
@export var ground_speed := 10.0
@export var ground_acceleration := 100.0
@export var air_speed := 10
@export var air_acceleration := 10.0
@export var friction := 10.0
@export var jump_speed := 10
@export var walk_speed := 4.0
@export var crouch_speed := 3.0
@export_range(1, 2) var crouch_height := 1.0
@export_range(2,4) var stand_height := 2.0
@export var posture_change_speed := 6.0

# Internal state tracking
var wish_velocity: Vector3 = Vector3.ZERO
var is_crouching := false
var is_walking := false
@onready var animation_tree := $CollisionShape3D/AnimationTree

# movement physics = acceleration → apply friction → gravity → collisions
func _physics_process(delta: float) -> void:
	var input_dir := get_input_direction()     # normalized wish direction
	is_crouching = Input.is_action_pressed("crouch")
	is_walking = Input.is_action_pressed("walk")
	var grounded = is_on_floor()
	
	# probably remove this eventually
	calculate_posture(delta)
	
	if grounded:
		if debug: print_debug('grounded')
		apply_ground_friction(delta)
		apply_ground_acceleration(input_dir, delta)
		apply_jump_velocity()
	else:
		if debug: print_debug('not grounded')
		apply_air_acceleration(input_dir, delta)
		apply_gravity(delta)
	
	self.velocity = self.wish_velocity
	var normalized_horizontal_velocity = Vector2(velocity.x, -velocity.z) * (1 / ground_speed)
	print_debug(normalized_horizontal_velocity)
	animation_tree['parameters/Locomotion/blend_position'] = normalized_horizontal_velocity
	if debug:
		print_debug('Velocity: ', self.velocity)
	move_and_slide()

func update_rotation(rotation_direction: Vector3):
	global_transform.basis = Basis.from_euler(rotation_direction)

func get_input_direction() -> Vector3:
	var input_dir = Input.get_vector("move_left","move_right","move_forward","move_backward")
	if debug: print_debug('input vector: ', input_dir)
	return Vector3(input_dir.x, 0, input_dir.y)

# Take the direction we are already going and reduce it by some amount
func apply_ground_friction(delta: float):
	var current_speed = self.wish_velocity.length()
	var drop_in_speed : float = current_speed * friction * delta
	var new_speed = max(current_speed - drop_in_speed, 0)
	
	# movement velocity is scaled according to the the new vs old speed
	# for example, if the current speed is 2 and the new speed is 1,
	# we'd scale our velocity by 1/2
	self.wish_velocity = self.wish_velocity.normalized() * new_speed
	if debug:
		print_debug('current speed: ', current_speed)
		print_debug('drop in speed: ', drop_in_speed)
		print_debug('new speed: ', new_speed)

# Apply acceleration in the direction of the inputs according to the current direction of the player
func apply_ground_acceleration(direction: Vector3, delta: float):
	var corrected_direction = (transform.basis * direction).normalized()
	self.wish_velocity += corrected_direction * ground_acceleration * delta
	var max_speed = calculate_max_speed()
	if self.wish_velocity.length() > max_speed:
		self.wish_velocity = self.wish_velocity.limit_length(max_speed)

# Air acceleration should be simliar to ground, but with less control
# Also, ignore clamping the vertical velocity
func apply_air_acceleration(direction: Vector3, delta: float):
	var corrected_direction = (transform.basis * direction).normalized()
	var wish_horizontal_velocity: Vector3 = self.wish_velocity + corrected_direction * air_acceleration * delta
	wish_horizontal_velocity.y = 0;
	if wish_horizontal_velocity.length() > air_speed:
		wish_horizontal_velocity = wish_horizontal_velocity.limit_length(air_speed)
	if debug: print_debug('wish_horizontal_velocity', wish_horizontal_velocity)
	self.wish_velocity = Vector3(wish_horizontal_velocity.x, self.wish_velocity.y, wish_horizontal_velocity.z)

func apply_jump_velocity():
	if Input.is_action_just_pressed("jump"):
		self.wish_velocity.y = jump_speed

func apply_gravity(delta: float):
	self.wish_velocity += get_gravity() * delta

func calculate_max_speed() -> float:
	if is_crouching: return crouch_speed
	if is_walking: return walk_speed
	return ground_speed

func calculate_posture(delta: float):
	var current_height: float = $CollisionShape3D.shape.height
	if is_crouching:
		current_height = max(current_height - (posture_change_speed * delta), crouch_height)
	else:
		current_height = min(current_height + (posture_change_speed * delta), stand_height)
	$CollisionShape3D.shape.height = current_height
	$CollisionShape3D/Body.mesh.height = current_height
	if debug: print_debug('current height: ', current_height)
