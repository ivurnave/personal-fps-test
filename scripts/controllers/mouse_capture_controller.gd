class_name MouseCaptureComponent extends Node

@export_category("Mouse Capture Settings")
@export var current_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED
@export var base_mouse_sensitivity := 0.005
@export_range(0, 2) var mouse_sensitivity := 1.0

var _capture_mouse: bool
var _mouse_input: Vector2

func _unhandled_input(event: InputEvent) -> void:
	_capture_mouse = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	capture_mouse_motion(event)

func _ready() -> void:
	Input.mouse_mode = current_mouse_mode

func _process(_delta: float) -> void:
	_mouse_input = Vector2.ZERO

func capture_mouse_motion(event: InputEvent):
	if _capture_mouse && event is InputEventMouseMotion:
		_mouse_input.x += -event.screen_relative.x * base_mouse_sensitivity * mouse_sensitivity
		_mouse_input.y += -event.screen_relative.y * base_mouse_sensitivity * mouse_sensitivity
