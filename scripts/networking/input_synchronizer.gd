extends MultiplayerSynchronizer
class_name InputSynchronizer


@export_category("Mouse Capture Settings")
@export var starting_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED
@export var base_mouse_sensitivity := 0.005
@export_range(0, 2) var mouse_sensitivity := 1.0

var _capture_mouse: bool

## Replicate these properties
var mouse_input : Vector2
var movement_input : Vector3
var jump_input : bool = false
var fire_input : bool = false
var reload_input : bool = false
var crouch_input : bool = false
var walk_input : bool = false
#var equip

func _ready() -> void:
	# Only process for the local player.
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_unhandled_input(is_multiplayer_authority())
	
	Input.mouse_mode = starting_mouse_mode
	_capture_mouse = true if starting_mouse_mode == Input.MOUSE_MODE_CAPTURED else false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_capture_mouse = !_capture_mouse
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if _capture_mouse else Input.MOUSE_MODE_VISIBLE
	
	if _capture_mouse:
		capture_mouse_motion(event)
	
	if event.is_action_pressed("jump"):
		do_jump.rpc()
	if event.is_action_pressed("reload"):
		do_reload.rpc()
	if event.is_action_pressed("fire"):
		do_fire.rpc()
	if event.is_action_released("fire"):
		do_release_fire.rpc()

func _process(_delta: float) -> void:
	mouse_input = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	movement_input = get_input_direction()
	crouch_input = Input.is_action_pressed("crouch")
	walk_input = Input.is_action_pressed("walk")


func capture_mouse_motion(event: InputEvent):
	if event is InputEventMouseMotion:
		mouse_input.x += -event.screen_relative.x * base_mouse_sensitivity * mouse_sensitivity
		mouse_input.y += -event.screen_relative.y * base_mouse_sensitivity * mouse_sensitivity

func get_input_direction() -> Vector3:
	var input_dir_raw = Input.get_vector("move_left","move_right","move_forward","move_backward")
	return Vector3(input_dir_raw.x, 0, input_dir_raw.y)

@rpc("call_local", "reliable")
func do_jump():
	jump_input = true

@rpc("call_local", "reliable")
func do_fire():
	fire_input = true

@rpc("call_local", "reliable")
func do_release_fire():
	fire_input = false

@rpc("call_local", "reliable")
func do_reload():
	reload_input = true
