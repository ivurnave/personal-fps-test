class_name RecoilController
extends Node3D

@export var recoil_pattern_scale = 0.0005

## Apply the recoil to the current basis and return the new direction
func apply_recoil_to_basis(
	current_basis: Basis,
	recoil: Vector2
) -> Vector3:
	var new_basis := Basis()
	# Pitch (up/down)d
	new_basis = new_basis.rotated(current_basis.x, -recoil.y)
	# Yaw (left/right)
	new_basis = new_basis.rotated(current_basis.y, -recoil.x)
	return (new_basis * current_basis.z * -1).normalized()

func get_current_recoil_and_update_heat(
	weapon_resource: WeaponResource,
	heat: float
):
	var spray_recoil = weapon_resource.get_spray_recoil_for_heat(heat) * recoil_pattern_scale
	var random_recoil = calculate_random_recoil(weapon_resource, heat)
	var mag_size = weapon_resource.magazine_size
	var recoil : Vector2 = spray_recoil + random_recoil
	var new_heat = heat + 1.0
	if (new_heat > mag_size):
		if weapon_resource.is_automatic:
			@warning_ignore("integer_division")
			new_heat = randf_range(mag_size - (mag_size / 4), mag_size)
		else:
			new_heat = mag_size
		
	return [recoil, new_heat]

func calculate_random_recoil(weapon_resource: WeaponResource, heat):
	var x_offset := 0.0
	var y_offset := 0.0
	var heat_offset = lerp(0, 100, heat / weapon_resource.magazine_size)
	x_offset = heat_offset
	y_offset = heat_offset
	return Vector2(randf_range(-x_offset, x_offset), randf_range(-y_offset, y_offset)) * recoil_pattern_scale
