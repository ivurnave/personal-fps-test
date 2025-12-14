extends SubViewport

@export var player : PlayerController
@export var main_camera : CameraController
@export var original_fov := 90.0
@export var max_speed_fov := 85.0

@onready var subview_camera = $ViewModelCamera
var temp_max_y_velocity = 30.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	size = get_window().size

func _process(_delta: float) -> void:
	subview_camera.global_transform = main_camera.global_transform

func _physics_process(_delta: float) -> void:
	var speed_weight = Vector2(player.velocity.x, player.velocity.z).length() / player.ground_speed
	subview_camera.fov = lerp(original_fov, max_speed_fov, speed_weight)
