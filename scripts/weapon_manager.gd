class_name WeaponManager
extends Node

@export var player : PlayerController
@export var mouse_capture: MouseCaptureComponent
@export var current_weapon : WeaponResource
@export var view_model : ViewModelArms
@export var camera : Camera3D
@export var weapon_audio_emitter : AudioStreamPlayer3D
@export var bullet_tracer_scene : PackedScene
@export var recoil_pattern_scale := 0.0008

## In order to keep ammo/rate of fire unique to each weapon, the weapon
## instance must be unique
var current_weapon_instance : WeaponResource
var current_weapon_model : Node3D
var heat := 0.0 ## Keep track of the heat of the current weapon
signal weapon_fire

func _ready() -> void:
	current_weapon_instance = current_weapon.duplicate(true)
	current_weapon_model = current_weapon_instance.weapon_model.instantiate()
	current_weapon_instance.weapon_manager = self
	view_model.weapon_slot.add_child(current_weapon_model)
	weapon_audio_emitter.stream = current_weapon_instance.fire_sound

func _unhandled_input(event: InputEvent) -> void:
	if mouse_capture._capture_mouse:
		if event.is_action_pressed("fire"):
			current_weapon_instance.trigger_down = true
		if event.is_action_released("fire"):
			current_weapon_instance.trigger_down = false

func _process(delta: float) -> void:
	if current_weapon_instance.is_automatic && current_weapon_instance.trigger_down:
		current_weapon_instance.try_fire()
	if !current_weapon_instance.trigger_down:
		heat = max(0.0, heat - delta * current_weapon_instance.recoil_cooldown_rate)


func fire() -> void:
	if current_weapon_instance:
		weapon_audio_emitter.play() # play sound
		var recoil = get_current_recoil_and_update_heat()
		weapon_fire.emit(recoil) # emit signal
		var raycast_results = fire_shot_raycast(recoil);
		var hit_position = raycast_results[0]
		get_tree()
		make_bullet_trail(hit_position)

func get_current_recoil_and_update_heat():
	var spray_recoil : Vector2 = current_weapon_instance.recoil_pattern.get_point_position(int(heat) % current_weapon_instance.recoil_pattern.point_count) * recoil_pattern_scale
	var random_recoil = calculate_random_recoil()
	print(random_recoil)
	var mag_size = current_weapon_instance.magazine_size
	var recoil : Vector2 = spray_recoil + random_recoil
	heat += 1.0
	if (heat > mag_size && current_weapon_instance.is_automatic):
		if current_weapon_instance.is_automatic:
			@warning_ignore("integer_division")
			heat = mag_size - (mag_size / 4)
		else:
			heat = mag_size
		
	return recoil

func calculate_random_recoil():
	var x_offset := 0.0
	var y_offset := 0.0
	var isAirborn = !player.is_on_floor()
	var player_speed = player.calculate_horizontal_speed()
	var heat_offset = lerp(0, 50, heat / current_weapon_instance.magazine_size)
	if isAirborn:
		x_offset = 200.0
		y_offset = 200.0
	else:
		var offset = (player_speed / player.ground_speed) * 200
		offset += heat_offset
		x_offset = offset
		y_offset = offset
	
	return Vector2(randf_range(-x_offset, x_offset), randf_range(-y_offset, y_offset)) * recoil_pattern_scale

func fire_shot_raycast(recoil: Vector2):
	var origin = camera.global_position
	var camera_forward = -camera.global_transform.basis.z
	var direction = apply_recoil_to_direction(camera_forward, recoil)
	
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

## Apply the recoil to the forward direction and return the new direction
func apply_recoil_to_direction(
	forward: Vector3,
	recoil: Vector2
) -> Vector3:
	var basis := Basis()

	# Pitch (up/down)
	basis = basis.rotated(camera.global_transform.basis.x, -recoil.y)

	# Yaw (left/right)
	basis = basis.rotated(camera.global_transform.basis.y, -recoil.x)

	return (basis * forward).normalized()

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
