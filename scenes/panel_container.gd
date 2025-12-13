class_name DebugPanel extends PanelContainer

@export var player : PlayerController
@onready var horizontal_speed_label = $VBoxContainer/HorizontalSpeedLabel
@onready var vertical_speed_label = $VBoxContainer/VerticalSpeedLabel
@onready var state_label = $VBoxContainer/StateLabel

func _process(_delta: float) -> void:
	horizontal_speed_label.text = "Horizontal Speed: " + str(Vector2(player.velocity.x, player.velocity.z).length())
	vertical_speed_label.text = "Vertical Speed: " + str(player.velocity.y)
	state_label.text = "State: " + str(player.movement_controller.state)
	
