extends Node
class_name PlayerInputsNetfox

@export_range(0, 2) var mouse_sensitivity := 1.0
var base_mouse_sensitivity := 0.005

# State to track
var movement_input : Vector3 = Vector3.ZERO
var look_angle: Vector2 = Vector2.ZERO
var jump_input : bool = false
var slot1 := false
var slot2 := false
var slot3 := false
var fire_input := false
var reload_input := false

# Internal
var _mouse_rotation: Vector2 = Vector2.ZERO

func _ready() -> void:
	set_process_unhandled_input(is_multiplayer_authority())
	NetworkTime.before_tick_loop.connect(_gather)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_rotation.y += event.relative.x * mouse_sensitivity * base_mouse_sensitivity
		_mouse_rotation.x += event.relative.y * mouse_sensitivity * base_mouse_sensitivity


# Called every network tick
func _gather():
	if !is_multiplayer_authority(): return
	movement_input = _get_input_direction()
	jump_input = Input.is_action_just_pressed("jump")
	look_angle = Vector2(-_mouse_rotation.y, -_mouse_rotation.x)
	fire_input = Input.is_action_just_pressed("fire")
	_mouse_rotation = Vector2.ZERO

func _get_input_direction() -> Vector3:
	var input_dir_raw = Input.get_vector("move_left","move_right","move_forward","move_backward")
	return Vector3(input_dir_raw.x, 0, input_dir_raw.y)
