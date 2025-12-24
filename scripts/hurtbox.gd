class_name Hurtbox
extends Area3D

enum HurtboxType {HEAD, BODY, LEGS}

@export var owner_enemy: Node
@export var type : HurtboxType = HurtboxType.BODY

func _ready() -> void:
	set_collision_layer_value(1, false) ## World
	set_collision_layer_value(2, false) ## Player movement
	set_collision_layer_value(3, true) ## Hurtboxes!!!

## TODO: apply hit should take weapon info and apply damage based on the
## weapon damage per hurtbox (head value vs body vs legs)
func apply_hit(damage: int, _hit_position: Vector3, _hit_normal: Vector3) -> void:
	if owner_enemy and owner_enemy.has_method("on_hit"):
		var modifier = 2.0 if type == HurtboxType.HEAD else 1.0
		owner_enemy.on_hit(damage * modifier)
