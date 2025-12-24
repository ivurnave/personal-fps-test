class_name Hitscan
extends Node3D

signal hit(hit_data: Dictionary)

const LAYER_WORLD := 1 << 0
const LAYER_HURTBOX := 1 << 2

func perform_hitscan(origin: Vector3, direction: Vector3):
	var query = PhysicsRayQueryParameters3D.create(
		origin,
		origin + direction * 999,
	)
	query.collide_with_areas = true
	query.collision_mask = LAYER_WORLD | LAYER_HURTBOX
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	if !result: return

	hit.emit(result)
	return result
