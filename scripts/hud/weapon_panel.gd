extends Control
class_name WeaponPanel

@onready var slot1 := $SlotsContainer/slot1
@onready var slot2 := $SlotsContainer/slot2
@onready var slot3 := $SlotsContainer/slot3
@onready var ammo_label := $AmmoBackground/Ammo

func update_ammo(weapon_state: WeaponResource):
	ammo_label.text = str(weapon_state.current_ammo_in_magazine, ' / ', weapon_state.reserve_ammo)

func remove_weapon_from_slot(weapon: WeaponResource):
	var slot_to_update = get_slot_for_weapon(weapon)
	slot_to_update.text = 'empty'

func update_slot_for_weapon(weapon_info: WeaponResource):
	var slot_to_update = get_slot_for_weapon(weapon_info)
	slot_to_update.text = weapon_info.weapon_name

func get_slot_for_weapon(weapon: WeaponResource) -> Label:
	var slot_to_update : Label
	match weapon.weapon_slot:
		"slot1":
			slot_to_update = slot1
		"slot2":
			slot_to_update = slot2
		"slot3":
			slot_to_update = slot3
	return slot_to_update

func _on_weapon_manager_weapon_fired(weapon_state: WeaponResource) -> void:
	update_ammo(weapon_state)
	update_slot_for_weapon(weapon_state)

func _on_weapon_manager_weapon_reloaded(weapon_state: WeaponResource) -> void:
	update_ammo(weapon_state)
	update_slot_for_weapon(weapon_state)

func _on_weapon_manager_weapon_switched(new_weapon: WeaponResource) -> void:
	update_ammo(new_weapon)
	update_slot_for_weapon(new_weapon)

func _on_weapon_manager_weapon_dropped(weapon: WeaponResource) -> void:
	remove_weapon_from_slot(weapon)

func _on_weapon_manager_weapon_pickup(weapon: WeaponResource) -> void:
	update_slot_for_weapon(weapon)
