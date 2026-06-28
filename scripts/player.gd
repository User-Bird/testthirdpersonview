extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# 1. Grab references to our nodes
@onready var camera_pivot = $CameraPivot
@onready var visual_model = $player

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# 2. THE FIX: Calculate direction based on where the CameraPivot is looking
	var direction = (camera_pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# 3. Rotate the visual model smoothly to face the walking direction
		visual_model.rotation.y = lerp_angle(visual_model.rotation.y, atan2(velocity.x, velocity.z), 0.15)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
