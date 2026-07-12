extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 3.0

@onready var spring_arm = $CameraPivot/SpringArm3D
@onready var visual_model = $player
# 1. Grab the AnimationPlayer that Godot auto-generated inside your glb
@onready var anim_player = $player/AnimationPlayer

# 2. Add a variable to track if we were just falling
var was_in_air = false

func _physics_process(delta: float) -> void:
	var gravity = get_gravity().y
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# ADD THIS TO FIX THE EXPLOSION:
	if velocity.y < -30.0: # Play with this number. -30 is a fast, safe fall.
		velocity.y = -30.0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (spring_arm.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	direction.y = 0
	direction = direction.normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# 3. The rotation offset fix is added here (+ PI / 2.0)
		var target_rotation = atan2(-velocity.x, -velocity.z) + (PI / 2.0)
		visual_model.rotation.y = lerp_angle(visual_model.rotation.y, target_rotation, 0.15)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# --- ANIMATION LOGIC ---
	if is_on_floor():
		if was_in_air:
			# We just hit the ground, play the heavy landing impact!
			anim_player.play("Jump_end")
		elif direction and anim_player.current_animation != "Jump_end":
			anim_player.play("Run", -1, 1.5)
		elif anim_player.current_animation != "Jump_end" or not anim_player.is_playing():
			anim_player.play("Idle")
	else:
		# We are in the air. Are we going up or down?
		if velocity.y > 0:
			anim_player.play("Jump_start")
		else:
			anim_player.play("Jump_loop")

	# Update our air tracking variable for the next frame
	was_in_air = not is_on_floor()

	move_and_slide()
