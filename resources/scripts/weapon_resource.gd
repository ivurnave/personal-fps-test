class_name WeaponResource
extends Resource

@export var weapon_model : PackedScene
@export var damage : float
@export var screen_recoil : float
@export var is_automatic : bool
@export var magazine_size : int
@export var total_ammo : int
@export var rate_of_fire : float
@export var movement_speed_modifier : float
@export var fire_sound : AudioStream
@export var recoil_pattern : Curve2D
@export var recoil_cooldown_rate : float

## Give weapon resource access to weapon mananger
var weapon_manager : WeaponManager

## Weapon logic
var last_fire_time : float
var ammo_in_magazine : int

var trigger_down := false:
	set(val):
		if trigger_down != val:
			trigger_down = val
		if trigger_down:
			on_trigger_down()
		else:
			on_trigger_up()

var is_equipped := false:
	set(val):
		if is_equipped != val:
			is_equipped = val
		if is_equipped:
			on_equip()
		else:
			on_unequip()

func on_trigger_down():
	try_fire()

func on_trigger_up():
	pass

func try_fire():
	if !can_fire():
		return false

	last_fire_time = Time.get_ticks_msec() * 0.001
	weapon_manager.fire()
	return true

func can_fire():
	if weapon_manager == null:
		return false
	var now := Time.get_ticks_msec() * 0.001
	var fire_interval := 1.0 / rate_of_fire
	if now - last_fire_time < fire_interval:
		return false

	# Optional: ammo checks here
	#if ammo_in_magazine <= 0:
		#return false
	return true

func on_equip():
	pass

func on_unequip():
	pass
