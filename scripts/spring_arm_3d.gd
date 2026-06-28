extends SpringArm3D

# How fast the camera looks around
var mouse_sensitivity := 0.005

func _ready() -> void:
	# This hides your mouse cursor and locks it to the game window
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	# Press the ESC key to quit the game and get your mouse back!
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

	# If the mouse moves, rotate the SpringArm
	if event is InputEventMouseMotion:
		# Move left and right
		rotation.y -= event.relative.x * mouse_sensitivity
		# Move up and down
		rotation.x -= event.relative.y * mouse_sensitivity
		
		# Clamp the up/down movement so the camera can't do a full backflip
		rotation.x = clamp(rotation.x, -deg_to_rad(80), deg_to_rad(45))
