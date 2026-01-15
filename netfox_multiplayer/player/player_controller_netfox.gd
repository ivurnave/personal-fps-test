extends CharacterBody3D
class_name PlayerControllerNetfox

@export var inputs : PlayerInputsNetfox
@export var ground_speed := 6.0
@export var walk_speed := 4.0
@export var crouch_speed := 3.0
@export var air_speed := 6.0
@export var jump_speed := 10.0

@onready var movement_controller: MovementControllerNetfox = $MovementController
@onready var camera_controller : CameraControllerNetfox = $CameraController
# @onready var view_model_effects : ViewModelEffectsNetfox = $CameraController/CameraEffects/Camera3D/Hand
@onready var view_model_effects : ViewModelEffectsNetfox = $CameraController/CameraEffects/Camera3D/ViewModel
@onready var camera : Camera3D = $CameraController/CameraEffects/Camera3D
@onready var hud : Control = $CameraController/CameraEffects/Camera3D/CanvasLayer/HUD
@onready var healthbar : ProgressBar = $CameraController/CameraEffects/Camera3D/CanvasLayer/HUD/HealthBar

@export var player_id : int:
	set(id):
		player_id = id
		inputs.set_multiplayer_authority(id)

var health := 100


func _ready() -> void:
	await get_tree().process_frame

	movement_controller.initialize(self)
	camera_controller.initialize(self)
	view_model_effects.initialize(self)
	if multiplayer.get_unique_id() == player_id:
		camera.current = true
		hud.visible = true
	else:
		camera.current = false
		hud.visible = false

func _rollback_tick(delta, _tick, _is_fresh):
	camera_controller.update(inputs.look_angle)
	movement_controller.update(delta)
	view_model_effects.update(delta)

	if health <= 0:
		queue_free()

func on_hit(damage: int):
	health -= damage
	healthbar.value =  health
