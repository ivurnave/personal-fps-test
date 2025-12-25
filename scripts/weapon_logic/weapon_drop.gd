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

func has_weapon():
	return can_pickup && get_children().size() > 0

func get_weapon_info():
	if has_weapon():
		var weapon: Weapon = get_child(0)
		return weapon.weapon_resource

#func try_get_weapon():
	#if has_weapon():
		#return get_child(0)
		#var children = get_children()
		#if children.size() > 0:
			#var weapon = get_children()[0]
			#remove_child(weapon)
			#return weapon

## Get the weapon child node and remove it from the drop
func get_weapon_and_remove_from_drop():
	if has_weapon():
		var weapon = get_child(0)
		remove_child(weapon)
		return weapon

func pass_weapon():
	pass
	
