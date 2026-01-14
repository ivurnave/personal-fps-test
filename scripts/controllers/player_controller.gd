class_name PlayerController extends CharacterBody3D

@export_subgroup("Movement Settings")
@export var ground_speed := 6.0
@export var air_speed := 6.0
@export var jump_speed := 10.0
@export var walk_speed := 3.0
@export var crouch_speed := 2.5
@export_range(1, 2) var crouch_height := 1.0
@export_range(2,4) var stand_height := 2.0
@export var posture_change_speed := 6.0
@export var inputs : InputSynchronizerRPC

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var movement_controller : MovementController = $Components/MovementController
#@onready var animation_controller : AnimationController = $Components/AnimationController
@onready var state_controller : StateController = $Components/StateController
#@onready var weapon_manager : WeaponManager = $Components/WeaponManager
@onready var camera_controller : CameraController = $CameraController
@onready var camera : Camera3D = $CameraController/CameraEffects/Camera3D
@onready var view_model_controller : ViewModelMovement = $CameraController/CameraEffects/Camera3D/ViewModelEffects 
@onready var rollback_synchronizer : RollbackSynchronizer = $RollbackSynchronizer

## Player Id = Multiplayer Peer ID
@export var player_id : int:
	set(id):
		player_id = id
		inputs.set_multiplayer_authority(id)

func _ready() -> void:
	camera.current = true if multiplayer.get_unique_id() == player_id else false
	movement_controller.initialize(self)
	rollback_synchronizer.process_settings()

func _physics_process(_delta: float) -> void:
	camera_controller.update_camera_for_mouse_movement(inputs.mouse_input)

func _rollback_tick(delta, _tick, _is_fresh):
	#animation_controller.update_posture(self, delta)
	camera_controller.update_camera_for_mouse_movement(inputs.mouse_input)
	#view_model_controller.update(delta)
	state_controller.detect_current_state()
	movement_controller.update(delta)

## Helper
func calculate_horizontal_speed():
	return Vector2(velocity.x, velocity.z).length()
