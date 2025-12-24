class_name WeaponResource
extends Resource

@export var weapon_name : String
@export_enum("slot1", "slot2", "slot3") var weapon_slot : String
@export var damage : float
@export var is_automatic : bool
@export var is_knife := false
@export var is_droppable := true
@export var magazine_size : int
@export var total_ammo : int
@export var rate_of_fire : float
@export var movement_speed_modifier : float
@export var fire_sound : AudioStream
@export var recoil_pattern : Curve2D
@export var recoil_cooldown_rate : float
@export var bullet_tracer : PackedScene

## Weapon / state
var last_fire_time : float
var ammo_in_magazine : int
var is_trigger_down := false:
	set(val):
		if is_trigger_down != val:
			is_trigger_down = val
		if is_trigger_down:
			on_trigger_down()
		else:
			on_trigger_up()

var is_equipped := false
var is_equipping := false
var is_reloading := false

signal weapon_fired

func on_trigger_down():
	try_fire()

func on_trigger_up():
	pass

## Recoil logic
func get_spray_recoil_for_heat(heat: float):
	if recoil_pattern:
		return recoil_pattern.get_point_position(int(heat) % recoil_pattern.point_count)
	return Vector2()

## Firing Logic
func try_fire():
	if !can_fire():
		return false
	weapon_fired.emit()
	last_fire_time = Time.get_ticks_msec() * 0.001
	return true

func can_fire():
	if is_reloading || is_equipping:
		return false
	var now := Time.get_ticks_msec() * 0.001
	var fire_interval := 1.0 / rate_of_fire
	if now - last_fire_time < fire_interval:
		return false

	# Optional: ammo checks here
	#if ammo_in_magazine <= 0:
		#return false
	return true
