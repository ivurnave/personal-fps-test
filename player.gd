class_name PlayerController extends CharacterBody3D

@export var speed = 10
@export_range(0,1) var move_acceleration = 0.1
@export var max_fall_speed = 30

@export_subgroup("Mouse Settings")
@export var mouse_sensitivity: float = 0.05

var _input_dir: Vector2 = Vector2.ZERO
var _movement_velocity: Vector3 = Vector3.ZERO

# movement physics = acceleration → apply friction → gravity → collisions

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y = clamp(velocity.y + (get_gravity().y * delta), -max_fall_speed, 200)
	
	_input_dir = Input.get_vector("move_left","move_right","move_forward","move_backward")
	var current_velocity = Vector2(_movement_velocity.x, _movement_velocity.z)
	var direction = (transform.basis * Vector3(_input_dir.x, 0, _input_dir.y)).normalized()
	
	if direction:
		current_velocity = lerp(current_velocity, Vector2(direction.x, direction.z) * speed, move_acceleration)
	else:
		current_velocity = current_velocity.move_toward(Vector2.ZERO, move_acceleration)
	
	_movement_velocity = Vector3(current_velocity.x, velocity.y, current_velocity.y)
	
	velocity = _movement_velocity
	move_and_slide()

func update_rotation(rotation_direction: Vector3):
	global_transform.basis = Basis.from_euler(rotation_direction)
