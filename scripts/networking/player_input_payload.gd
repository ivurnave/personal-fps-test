extends Resource
class_name PlayerInputPayload

var tick : int

var mouse_input : Vector2
var movement_input : Vector3
var jump : bool = false
var fire : bool = false
var reload : bool = false
var crouch : bool = false
var walk : bool = false
var slot1 : bool = false
var slot2 : bool = false
var slot3 : bool = false

static func create(props: Dictionary) -> PlayerInputPayload:
	var instance = PlayerInputPayload.new()
	for key in props:
		if key in instance:
			instance.set(key, props[key])
	return instance

func _to_string() -> String:
	return str(inst_to_dict(self))
