class_name WeaponManager
extends Node

@export var mouse_capture: MouseCaptureComponent
@export var current_weapon : WeaponResource
@export var view_model : ViewModelArms
@export var camera : Camera3D
@export var weapon_audio_emitter : AudioStreamPlayer3D
@export var bullet_tracer_scene : PackedScene

## In order to keep ammo/rate of fire unique to each weapon, the weapon
## instance must be unique
var current_weapon_instance : WeaponResource
var current_weapon_model : Node3D
signal weapon_fire

func _unhandled_input(event: InputEvent) -> void:
	if mouse_capture._capture_mouse:
		if event.is_action_pressed("fire"):
			current_weapon_instance.trigger_down = true
		if event.is_action_released("fire"):
			current_weapon_instance.trigger_down = false

func _ready() -> void:
	current_weapon_instance = current_weapon.duplicate(true)
	current_weapon_model = current_weapon_instance.weapon_model.instantiate()
	current_weapon_instance.weapon_manager = self
	view_model.weapon_slot.add_child(current_weapon_model)
	weapon_audio_emitter.stream = current_weapon_instance.fire_sound

func fire() -> void:
	if current_weapon_instance:
		weapon_fire.emit(current_weapon_instance) # emit signal
		weapon_audio_emitter.play() # play sound
		var raycast_results = fire_shot_raycast();
		var hit_position = raycast_results[0]
		make_bullet_trail(hit_position)

func fire_shot_raycast():
	var origin = camera.global_position
	var direction = -camera.global_transform.basis.z
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		origin,
		origin + direction * 999
	)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	var hit_position: Vector3
	var hit_normal: Vector3
	if result:
		hit_position = result.position
		hit_normal = result.normal
	else:
		hit_position = origin + direction * 999
	return [hit_position, hit_normal]

func make_bullet_trail(target_position: Vector3) -> void:
	var muzzle_node = view_model.weapon_slot.find_child('Muzzle', true, false)
	var start_position = muzzle_node.global_position
	var minimum_path_length := 3.0 ## Don't show tracers if the path to target is less than this!
	if (target_position - start_position).length() > minimum_path_length:
		var bullet_tracer : BulletTracer = bullet_tracer_scene.instantiate()
		add_sibling(bullet_tracer)
		bullet_tracer.global_position = start_position
		bullet_tracer.target_position = target_position
		bullet_tracer.look_at(target_position)
