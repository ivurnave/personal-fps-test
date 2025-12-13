class_name PlayerController extends CharacterBody3D

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

@export_subgroup("Controllers")
@export var movement_controller : MovementController
@export var animation_controller : AnimationController


# Internal state tracking
var is_crouching := false
var is_walking := false

#@onready var animation_tree := $CollisionShape3D/AnimationTree

func _ready() -> void:
	movement_controller.initialize(self)

# movement physics = acceleration → apply friction → gravity → collisions
func _physics_process(delta: float) -> void:
	is_crouching = Input.is_action_pressed("crouch")
	is_walking = Input.is_action_pressed("walk")
	
	# probably remove this eventually
	calculate_posture(delta)
	
	# This is where we actually do the calculations based on the state of the player...
	movement_controller.update(delta)
	
	animation_controller.processAnimationBasedOnState()

func update_rotation(rotation_direction: Vector3):
	global_transform.basis = Basis.from_euler(rotation_direction)

# TODO: Rework this
func calculate_posture(delta: float):
	var current_height: float = $CollisionShape3D.shape.height
	if is_crouching:
		current_height = max(current_height - (posture_change_speed * delta), crouch_height)
	else:
		current_height = min(current_height + (posture_change_speed * delta), stand_height)
	$CollisionShape3D.shape.height = current_height
	$CollisionShape3D/Body.mesh.height = current_height
