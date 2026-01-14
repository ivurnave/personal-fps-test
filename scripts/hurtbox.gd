class_name Hurtbox
extends Area3D

enum HurtboxType {HEAD, BODY, LEGS}

@export var owning_node: Node
@export var type : HurtboxType = HurtboxType.BODY

func _ready() -> void:
	set_collision_layer_value(1, false) ## World
	set_collision_layer_value(2, false) ## Player movement
	set_collision_layer_value(3, true) ## Hurtboxes!!!

# func on_hit(damage: int, _hit_position: Vector3, _hit_normal: Vector3) -> void:
# 	if owning_node and owning_node.has_method("on_hit"):
# 		var modifier = 2.0 if type == HurtboxType.HEAD else 1.0
# 		owning_node.on_hit(damage * modifier)

func on_hit(damage: int) -> void:
	if owning_node and owning_node.has_method("on_hit"):
		var modifier = 2.0 if type == HurtboxType.HEAD else 1.0
		owning_node.on_hit(damage * modifier)