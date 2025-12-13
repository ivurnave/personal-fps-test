extends SubViewport

@onready var subview_camera = $Camera3D
@onready var main_camera = $"../../CameraController"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	size = get_window().size

func _process(_delta: float) -> void:
	subview_camera.global_transform = main_camera.global_transform
