extends RigidBody3D
class_name WeaponDrop

const LAYER_WORLD := 1 << 0
const LAYER_WEAPON_PICKUP := 1 << 3

var can_pickup = false

func _ready() -> void:
	collision_layer = LAYER_WEAPON_PICKUP
	get_tree().create_timer(1.0).timeout.connect(allow_pickup)

func allow_pickup():
	can_pickup = true

func try_get_weapon():
	if can_pickup:
		var children = get_children()
		if children.size() > 0:
			var weapon = get_children()[0]
			remove_child(weapon)
			return weapon
