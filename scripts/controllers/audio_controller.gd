class_name AudioController
extends Node

@export var player : PlayerController
@export var wind_stream : AudioStreamPlayer
@export var step_audio_stream : AudioStreamPlayer3D
@export var landing_loud : AudioStreamPlayer3D
@export var landing_soft : AudioStreamPlayer3D
@export var step_speed_threshold := 4

var step_frequency := 0.4
var step_timer := 0.0
var min_wind_volume := -50.0
var max_wind_volume := 0.0


func _physics_process(delta: float) -> void:
	var player_speed = player.velocity.length()
	var player_horizontal_speed = player.calculate_horizontal_speed()
	if (player_horizontal_speed > step_speed_threshold && player.state_controller.current_state == 'grounded'):
		# player is moving here
		step_timer += delta
		var can_play_footstep = (step_timer >= step_frequency)
		if can_play_footstep:
			step_audio_stream.play()
			step_timer = 0.0
	else:
		step_timer = max(0.0,step_timer - delta * 0.5)
	if player_speed > 10:
		wind_stream.volume_db = clampf(lerp(min_wind_volume, max_wind_volume, player_speed / 30), min_wind_volume, max_wind_volume)
	else:
		wind_stream.volume_db = min_wind_volume

func _on_state_controller_landed_loud() -> void:
	landing_loud.play()

func _on_state_controller_landed_soft() -> void:
	landing_soft.play()
