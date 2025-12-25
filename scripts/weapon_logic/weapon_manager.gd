class_name WeaponManager
extends Node

## Starting values
@export var slot_1_weapon_scene : PackedScene
@export var slot_2_weapon_scene : PackedScene
@export var slot_3_weapon_scene : PackedScene
@export var weapon_drop_force := 30.0

## References
@export var view_model : ViewModelArms
@export var camera_effects : CameraEffectsController
@export var camera : Camera3D

var current_weapon : Weapon
var current_weapon_slot : String
var weapon_dictionary : Dictionary[String, Weapon]

signal weapon_switched(weapon: WeaponResource)
signal weapon_fired(weapon: WeaponResource)
signal weapon_reloaded(weapon: WeaponResource)
signal weapon_dropped(weapon: WeaponResource)
signal weapon_pickup(weapon: WeaponResource)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		current_weapon.trigger_down()
	if event.is_action_released("fire"):
		current_weapon.trigger_up()
	if event.is_action_pressed("slot1"): equip_weapon("slot1")
	if event.is_action_pressed("slot2"): equip_weapon("slot2")
	if event.is_action_pressed("slot3"): equip_weapon("slot3")
	if event.is_action_pressed("reload"): current_weapon.start_reload()
	if event.is_action_pressed("drop_weapon"): drop_current_weapon()

func _ready():
	if slot_1_weapon_scene: weapon_dictionary.set("slot1", slot_1_weapon_scene.instantiate())
	if slot_2_weapon_scene: weapon_dictionary.set("slot2", slot_2_weapon_scene.instantiate())
	if slot_3_weapon_scene: weapon_dictionary.set("slot3", slot_3_weapon_scene.instantiate())
	equip_next_available_weapon()

func equip_weapon(slot: String):
	var new_weapon : Weapon = weapon_dictionary.get(slot)
	if slot == current_weapon_slot || !new_weapon:
		return
	if current_weapon:
		put_away_current_weapon()
		disconnect_weapon_signals()
		view_model.weapon_slot.remove_child(current_weapon)
	current_weapon = new_weapon
	current_weapon.first_person_camera = camera
	view_model.weapon_slot.add_child(current_weapon)
	current_weapon_slot = slot
	connect_weapon_signals()
	current_weapon.equip()
	weapon_switched.emit(current_weapon.weapon_resource)

func drop_current_weapon():
	if current_weapon.weapon_resource.is_droppable:
		# Stop whatever we're doing with the weapon
		current_weapon.put_away()
		
		# Emit the weapon we are dropping
		weapon_dropped.emit(current_weapon.weapon_resource)
		
		# Spawn new weapon drop to hold the weapon
		pass_current_weapon_to_dropped_weapon(current_weapon)
		
		# Cleanup signals and tracking of dropped weapon
		disconnect_weapon_signals()
		weapon_dictionary[current_weapon_slot] = null
		current_weapon = null
		
		# Choose next available weapon (will always at least be knife)
		equip_next_available_weapon()

func equip_next_available_weapon():
	if (weapon_dictionary.get("slot1")): equip_weapon("slot1")
	elif (weapon_dictionary.get("slot2")): equip_weapon("slot2")
	elif (weapon_dictionary.get("slot3")): equip_weapon("slot3")

func put_away_current_weapon():
	current_weapon.put_away()
	disconnect_weapon_signals()

## Spawn new weapon drop to hold the weapon
func pass_current_weapon_to_dropped_weapon(curr: Weapon):
	var dropped_weapon = WeaponDrop.new()
	get_tree().get_root().add_child(dropped_weapon)
	dropped_weapon.global_position = view_model.global_position
	curr.get_parent().remove_child(curr)
	dropped_weapon.add_child(curr)
	
	## Add impulse to weapon drop in direction of camera (and up a bit)
	var impulse_direction = view_model.global_basis.z.normalized()
	dropped_weapon.apply_central_impulse(impulse_direction * weapon_drop_force) 

## Signals for weapon

func connect_weapon_signals():
	current_weapon.recoil_signal.connect(camera_effects.on_weapon_recoil)
	current_weapon.fired.connect(emit_fired_signal)
	current_weapon.reloaded.connect(emit_reloaded_signal)

func disconnect_weapon_signals():
	if current_weapon.recoil_signal.is_connected(camera_effects.on_weapon_recoil):
		current_weapon.recoil_signal.disconnect(camera_effects.on_weapon_recoil)
	if current_weapon.fired.is_connected(emit_fired_signal):
		current_weapon.fired.disconnect(emit_fired_signal)
	if current_weapon.reloaded.is_connected(emit_reloaded_signal):
		current_weapon.reloaded.disconnect(emit_reloaded_signal)

func emit_fired_signal(resource: WeaponResource):
	weapon_fired.emit(resource)

func emit_reloaded_signal(resource: WeaponResource):
	weapon_reloaded.emit(resource)

func _on_pick_up_detector_body_entered(weapon_drop: WeaponDrop) -> void:
	var new_weapon_info = weapon_drop.get_weapon_info()
	if new_weapon_info && weapon_dictionary.get(new_weapon_info.weapon_slot) == null:
		var new_weapon = weapon_drop.get_weapon_and_remove_from_drop()
		weapon_dictionary.set(new_weapon_info.weapon_slot, new_weapon)
		weapon_pickup.emit(new_weapon.weapon_resource)
