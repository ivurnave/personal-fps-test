class_name Weapon
extends CollisionShape3D

#@export var first_person_camera : Camera3D
@export var weapon_resource : WeaponResource
@onready var muzzle : Node3D = $Muzzle
@onready var hitscan : Hitscan = $Hitscan
@onready var fire_sound := $FireSound
@onready var recoil_controller : RecoilController = $RecoilController
@onready var animation_player : AnimationPlayer = $AnimationPlayer

signal fired(weapon_resource: WeaponResource)
signal reloaded(weapon_resource: WeaponResource)
signal recoil_signal(recoil: Vector2)

var heat := 0.0
var first_person_camera : Camera3D

func _ready() -> void:
	weapon_resource.on_first_equip()
	first_person_camera = get_viewport().get_camera_3d()
	fire_sound.stream = weapon_resource.fire_sound
	animation_player.play('equip')

func _process(delta: float) -> void:
	# Handle automatic weapons
	if weapon_resource.is_trigger_down && weapon_resource.is_automatic && !weapon_resource.is_equipping:
		fire()
	# Reduce heat if the trigger isn't down
	if !weapon_resource.is_trigger_down:
		heat = max(0.0, heat - delta * weapon_resource.recoil_cooldown_rate)

## Called via weapon manager
func trigger_down():
	weapon_resource.is_trigger_down = true
	fire()

## Called via weapon manager
func trigger_up():
	weapon_resource.is_trigger_down = false

## Called via weapon resource
func fire():
	var did_weapon_fire = weapon_resource.try_fire()
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
	if weapon_resource.can_reload():
		weapon_resource.is_reloading = true
		animation_player.play("reload")

## Don't call this directly! It should be called from within the reload animation
func reload():
	weapon_resource.calculate_ammo()

## Called via weapon manager
func equip():
	animation_player.play("equip")

## Called via weapon manager
func put_away():
	animation_player.stop()
	weapon_resource.is_reloading = false
	weapon_resource.is_equipping = false
	weapon_resource.is_trigger_down = false


## Animation methods
func on_reload_end():
	weapon_resource.calculate_ammo() ## Temp!!! move call to reload animation
	weapon_resource.is_reloading = false
	reloaded.emit(weapon_resource)

func on_weapon_start_equip():
	weapon_resource.is_trigger_down = false
	weapon_resource.is_equipping = true

func on_weapon_equipped():
	weapon_resource.is_equipping = false
	weapon_resource.is_equipped = true

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
