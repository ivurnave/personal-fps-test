class_name Weapon
extends CollisionShape3D

@export var weapon_resource : WeaponResource
@onready var muzzle : Node3D = $Muzzle
@onready var hitscan : Hitscan = $Hitscan
@onready var fire_sound := $FireSound
@onready var recoil_controller : RecoilController = $RecoilController
@onready var animation_player : AnimationPlayer = $AnimationPlayer
var first_person_camera : Camera3D

signal fired(weapon_resource: WeaponResource)
signal reloaded(weapon_resource: WeaponResource)
signal recoil_signal(recoil: Vector2)

## Weapon state
var heat := 0.0
var last_fire_time : float
var current_ammo_in_magazine : int
var reserve_ammo : int
var is_trigger_down := false
var is_equipped := false
var is_equipping := false
var is_reloading := false


func _ready() -> void:
	#weapon_resource.on_first_equip()
	current_ammo_in_magazine = weapon_resource.magazine_size
	reserve_ammo = weapon_resource.total_ammo - weapon_resource.magazine_size
	fire_sound.stream = weapon_resource.fire_sound
	animation_player.play('equip')

func _process(delta: float) -> void:
	# Handle automatic weapons
	if weapon_resource.is_automatic && is_trigger_down && !is_equipping:
		fire()
	# Reduce heat if the trigger isn't down
	if !is_trigger_down:
		heat = max(0.0, heat - delta * weapon_resource.recoil_cooldown_rate)

## Called via weapon manager
func trigger_down():
	#weapon_resource.is_trigger_down = true
	is_trigger_down = true
	fire()

## Called via weapon manager
func trigger_up():
	#weapon_resource.is_trigger_down = false
	is_trigger_down = false

## Called via weapon resource
func fire():
	#var did_weapon_fire = weapon_resource.try_fire()
	var did_weapon_fire = _try_fire()
	if !did_weapon_fire:
		return
	
	## Do all calculations based on weapon firing
	var recoil
	if weapon_resource.is_knife:
		recoil = Vector2()
	else:
		var data = recoil_controller.get_current_recoil_and_update_heat(weapon_resource, heat)
		recoil = data[0]
		heat = data[1]
		var direction = recoil_controller.apply_recoil_to_basis(first_person_camera.global_basis, recoil)
		var hitscan_result = hitscan.perform_hitscan(first_person_camera.global_position, direction)
		if hitscan_result:
			make_bullet_trail(hitscan_result.position)
			GlobalDecalEffectsSpawner.spawn_decal(
				hitscan_result.position,
				hitscan_result.normal,
				hitscan_result.collider
			)
			if hitscan_result.collider is Hurtbox:
				hitscan_result.collider.apply_hit(
					weapon_resource.damage,
					hitscan_result.position,
					hitscan_result.normal
				)
	fire_sound.play()
	animation_player.play("fire")
	recoil_signal.emit(recoil)
	fired.emit(weapon_resource)

## Called via weapon manager
func start_reload():
	#if weapon_resource.can_reload():
	if _can_reload():
		#weapon_resource.is_reloading = true
		is_reloading = true
		animation_player.play("reload")

## Weapon State

## Firing Logic
func _try_fire() -> bool:
	if !_can_fire():
		return false
	if !weapon_resource.is_knife:
		current_ammo_in_magazine -= 1
	last_fire_time = Time.get_ticks_msec() * 0.001
	return true

func _can_fire():
	if is_reloading || is_equipping:
		return false
	var now := Time.get_ticks_msec() * 0.001
	var fire_interval := 1.0 / weapon_resource.rate_of_fire
	if now - last_fire_time < fire_interval:
		return false

	# Optional: ammo checks here
	if current_ammo_in_magazine <= 0:
		return false
	return true

func _can_reload():
	if is_reloading: return false
	if current_ammo_in_magazine == weapon_resource.magazine_size: return false
	if weapon_resource.is_knife: return false
	if reserve_ammo == 0: return false
	return true

func _calculate_ammo():
	var ammo_to_add = min(weapon_resource.magazine_size - current_ammo_in_magazine, reserve_ammo)
	reserve_ammo -= ammo_to_add
	current_ammo_in_magazine += ammo_to_add

## Don't call this directly! It should be called from within the reload animation
func reload():
	#weapon_resource.calculate_ammo()
	_calculate_ammo()

## Called via weapon manager
func equip():
	animation_player.play("equip")

## Called via weapon manager
func put_away():
	animation_player.stop()
	#weapon_resource.is_reloading = false
	#weapon_resource.is_equipping = false
	#weapon_resource.is_trigger_down = false
	is_reloading = false
	is_equipping = false
	is_trigger_down = false

## Animation methods
func on_reload_end():
	#weapon_resource.calculate_ammo() ## Temp!!! move call to reload animation
	#weapon_resource.is_reloading = false
	_calculate_ammo() ## Temp!!! move call to reload animation
	is_reloading = false
	reloaded.emit(weapon_resource)

func on_weapon_start_equip():
	#weapon_resource.is_trigger_down = false
	#weapon_resource.is_equipping = true
	is_trigger_down = false
	is_equipping = true

func on_weapon_equipped():
	#weapon_resource.is_equipping = false
	#weapon_resource.is_equipped = true
	is_equipping = false
	is_equipped = true

## Misc
func make_bullet_trail(target_position: Vector3) -> void:
	var start_position = muzzle.global_position
	var minimum_path_length := 3.0 ## Don't show tracers if the path to target is less than this!
	if (target_position - start_position).length() > minimum_path_length:
		var bullet_tracer_instance : BulletTracer = weapon_resource.bullet_tracer.instantiate()
		add_sibling(bullet_tracer_instance)
		bullet_tracer_instance.global_position = start_position
		bullet_tracer_instance.target_position = target_position
		bullet_tracer_instance.look_at(target_position)
