extends NetworkWeaponHitscan3D
class_name WeaponNetfox

@export var fire_cooldown: float = 0.25
@export var inputs: PlayerInputsNetfox
@export var bullet_tracer : PackedScene
@export var muzzle_position : Node3D
@export var weapon_damage : int = 10
@export var camera : Camera3D

@onready var fire_sound: AudioStreamPlayer3D = $FireSound
@onready var equip_sound: AudioStreamPlayer3D = $EquipSound
@onready var reload_sound: AudioStreamPlayer3D = $ReloadSound
@onready var animation_player : AnimationPlayer = $AnimationPlayer
var last_fire: int = -1

signal weapon_fired

func _ready():
	NetworkTime.on_tick.connect(_tick)

func _tick(_delta: float, _t: int):
	if inputs.fire_input:
		fire()

func _can_fire() -> bool:
	return NetworkTime.seconds_between(last_fire, NetworkTime.tick) >= fire_cooldown

func _can_peer_use(peer_id: int) -> bool:
	return peer_id == inputs.get_multiplayer_authority()

func _on_fire():
	fire_sound.play()
	animation_player.play('fire')
	weapon_fired.emit()
	
func _after_fire():
	last_fire = NetworkTime.tick

func _on_hit(result: Dictionary):
	_make_bullet_trail(result.position)
	GlobalDecalEffectsSpawner.spawn_decal(
		result.position,
		result.normal,
		result.collider
	)
	if result.collider.has_method("on_hit"):
		print('should be damaging')
		result.collider.on_hit(weapon_damage)

# ## I think I'd want to override this method to get access to introduce spread to the raycast
func _get_data() -> Dictionary:
	# Collect data needed to synchronize the firing event.
	return {
		"origin": camera.global_transform.origin,
		"direction": -camera.global_transform.basis.z  # Assuming forward direction.
	}

func _make_bullet_trail(target_position: Vector3) -> void:
	var start_position = muzzle_position.global_position
	var minimum_path_length := 3.0 ## Don't show tracers if the path to target is less than this!
	if (target_position - start_position).length() > minimum_path_length:
		var bullet_tracer_instance : BulletTracer = bullet_tracer.instantiate()
		add_sibling(bullet_tracer_instance)
		bullet_tracer_instance.global_position = start_position
		bullet_tracer_instance.target_position = target_position
		bullet_tracer_instance.look_at(target_position)