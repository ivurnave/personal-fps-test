class_name DebugPanel extends PanelContainer

@export var player : PlayerController
@export var state_controller : StateController
@onready var horizontal_speed_label = $VBoxContainer/HorizontalSpeedLabel
@onready var vertical_speed_label = $VBoxContainer/VerticalSpeedLabel
@onready var movement_state_label = $VBoxContainer/MovementStateLabel
@onready var state_label  = $VBoxContainer/StateLabel

func _process(_delta: float) -> void:
	horizontal_speed_label.text = "Horizontal Speed: " + str(Vector2(player.velocity.x, player.velocity.z).length())
	vertical_speed_label.text = "Vertical Speed: " + str(player.velocity.y)
	movement_state_label.text = "Movement State: " + str(player.movement_controller.state)
	state_label.text = "State: " + str(state_controller.current_state)
