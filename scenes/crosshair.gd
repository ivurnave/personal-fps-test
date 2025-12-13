class_name Crosshair extends Control

# Export variables allow you to easily change these in the Inspector
@export var dot_radius: float = 3.0
@export var dot_color: Color = Color.WHITE

# Godot 4
func _ready():
	# Since Control nodes don't resize the same way as Node2D, 
	# setting the minimum size helps the CenterContainer place it correctly.
	# Set the size to be large enough to contain the dot.
	var size_val = dot_radius * 2
	set_custom_minimum_size(Vector2(size_val, size_val))
	
	# Request the engine to call _draw() for the first time
	queue_redraw()

# This function is called every time a redraw is needed
func _draw():
	# 1. Calculate the center point
	# In a Control node's local space, Vector2(0, 0) is the top-left corner.
	# The center is half of the node's size.
	var center_point = size / 2

	# 2. Draw the filled circle (the 'dot')
	# draw_circle(center_position, radius, color)
	draw_circle(center_point, dot_radius, dot_color)

# Optional: Call this function whenever a property changes (like the radius)
# to make the crosshair dynamic.
func update_crosshair():
	queue_redraw()
