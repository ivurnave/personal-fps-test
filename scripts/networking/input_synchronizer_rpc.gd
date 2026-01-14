extends Node
class_name InputSynchronizerRPC


@export_category("Mouse Capture Settings")
@export var starting_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED
@export var base_mouse_sensitivity := 0.005
@export_range(0, 2) var mouse_sensitivity := 1.0

var should_capture_mouse: bool

var mouse_input : Vector2 = Vector2.ZERO
var movement_input : Vector3 = Vector3.ZERO
var jump_input : bool = false
var fire_input : bool = false
var reload_input : bool = false
var crouch_input : bool = false
var walk_input : bool = false
var slot1 : bool = false
var slot2 : bool = false
var slot3 : bool = false


#func _ready() -> void:
	## Only process for the local player.
	#set_process(is_multiplayer_authority())
	#set_physics_process(is_multiplayer_authority())
	#set_process_unhandled_input(is_multiplayer_authority())
	#
	#Input.mouse_mode = starting_mouse_mode
	#should_capture_mouse = true if starting_mouse_mode == Input.MOUSE_MODE_CAPTURED else false

func _ready() -> void:
	NetworkTime.before_tick_loop.connect(_gather)
	NetworkTime.after_tick_loop.connect(_reset)
	set_process(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())
	set_process_unhandled_input(is_multiplayer_authority())
	
	Input.mouse_mode = starting_mouse_mode
	should_capture_mouse = true if starting_mouse_mode == Input.MOUSE_MODE_CAPTURED else false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		should_capture_mouse = !should_capture_mouse
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if should_capture_mouse else Input.MOUSE_MODE_VISIBLE
	if should_capture_mouse:
		capture_mouse_motion(event)

func _gather():
	if !is_multiplayer_authority(): return
	movement_input = _get_input_direction()
	crouch_input = Input.is_action_pressed("crouch")
	walk_input = Input.is_action_pressed("walk")
	jump_input = Input.is_action_just_pressed("jump")
	fire_input = Input.is_action_pressed("fire")
	reload_input = Input.is_action_just_pressed("reload")
	slot1 = Input.is_action_just_pressed("slot1")
	slot2 = Input.is_action_just_pressed("slot2")
	slot3 = Input.is_action_just_pressed("slot3")
	
	print(mouse_input)

func _reset():
	mouse_input = Vector2.ZERO

#func _physics_process(_delta: float) -> void:
	#movement_input = get_input_direction()
	#crouch_input = Input.is_action_pressed("crouch")
	#walk_input = Input.is_action_pressed("walk")
	#jump_input = Input.is_action_just_pressed("jump")
	#fire_input = Input.is_action_pressed("fire")
	#reload_input = Input.is_action_just_pressed("reload")
	#slot1 = Input.is_action_just_pressed("slot1")
	#slot2 = Input.is_action_just_pressed("slot2")
	#slot3 = Input.is_action_just_pressed("slot3")
	#
	#send_inputs_to_server({
		#"tick": tick,
		#"movement_input": movement_input,
		#"mouse_input": mouse_input,
		#"jump_input" : jump_input,
		#"fire_input" : fire_input,
		#"reload_input" : reload_input,
		#"crouch_input" : crouch_input,
		#"walk_input" : walk_input,
		#"slot1" : slot1,
		#"slot2" : slot2,
		#"slot3" : slot3,
	#})
	#
	#mouse_input = Vector2.ZERO
	#tick += 1
#
func capture_mouse_motion(event: InputEvent):
	if event is InputEventMouseMotion:
		mouse_input.x += -event.screen_relative.x * base_mouse_sensitivity * mouse_sensitivity
		mouse_input.y += -event.screen_relative.y * base_mouse_sensitivity * mouse_sensitivity
#
func _get_input_direction() -> Vector3:
	var input_dir_raw = Input.get_vector("move_left","move_right","move_forward","move_backward")
	return Vector3(input_dir_raw.x, 0, input_dir_raw.y)
