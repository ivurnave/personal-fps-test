extends Node
class_name MouseCaptureComponent

@export_category("Mouse Capture Settings")
@export var starting_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED
@export var base_mouse_sensitivity := 0.005
@export_range(0, 2) var mouse_sensitivity := 1.0

var _capture_mouse: bool
var _mouse_input: Vector2

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		_capture_mouse = !_capture_mouse
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if _capture_mouse else Input.MOUSE_MODE_VISIBLE
	
	if _capture_mouse:
		capture_mouse_motion(event)

func _ready() -> void:
	Input.mouse_mode = starting_mouse_mode
	_capture_mouse = true if starting_mouse_mode == Input.MOUSE_MODE_CAPTURED else false

func _process(_delta: float) -> void:
	_mouse_input = Vector2.ZERO

func capture_mouse_motion(event: InputEvent):
	if event is InputEventMouseMotion:
		_mouse_input.x += -event.screen_relative.x * base_mouse_sensitivity * mouse_sensitivity
		_mouse_input.y += -event.screen_relative.y * base_mouse_sensitivity * mouse_sensitivity
