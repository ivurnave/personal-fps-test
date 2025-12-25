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
var current_ammo_in_magazine : int
var reserve_ammo : int
var is_trigger_down := false
var is_equipped := false
var is_equipping := false
var is_reloading := false

## Recoil logic
func get_spray_recoil_for_heat(heat: float):
	if recoil_pattern:
		return recoil_pattern.get_point_position(int(heat) % recoil_pattern.point_count)
	return Vector2()

## Firing Logic
func try_fire() -> bool:
	if !can_fire():
		return false
	if !is_knife:
		current_ammo_in_magazine -= 1
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
	if current_ammo_in_magazine <= 0:
		return false
	return true

func on_first_equip():
	current_ammo_in_magazine = magazine_size
	reserve_ammo = total_ammo - magazine_size

func can_reload():
	if is_reloading: return false
	if current_ammo_in_magazine == magazine_size: return false
	if is_knife: return false
	if reserve_ammo == 0: return false
	return true

func calculate_ammo():
	var ammo_to_add = min(magazine_size - current_ammo_in_magazine, reserve_ammo)
	reserve_ammo -= ammo_to_add
	current_ammo_in_magazine += ammo_to_add
