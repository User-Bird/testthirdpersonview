extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 3.0

@onready var spring_arm = $CameraPivot/SpringArm3D
@onready var visual_model = $player
@onready var anim_player = $player/AnimationPlayer
@onready var particles_front1 = $player/Armature/Skeleton3D/Emitter_Front1/GPUParticles3D
@onready var particles_back1 = $player/Armature/Skeleton3D/Emitter_Back1/GPUParticles3D
@onready var particles_front2 = $player/Armature/Skeleton3D/Emitter_Front2/GPUParticles3D
@onready var particles_back2 = $player/Armature/Skeleton3D/Emitter_Back2/GPUParticles3D

# Variable to track if we were just falling
var was_in_air = false

func _physics_process(delta: float) -> void:
	var gravity = get_gravity().y
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Terminal velocity to prevent falling through the floor
	if velocity.y < -30.0: 
		velocity.y = -30.0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement input and camera-relative direction
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (spring_arm.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	direction.y = 0
	direction = direction.normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# Rotation offset fix (+ PI / 2.0)
		var target_rotation = atan2(-velocity.x, -velocity.z) + (PI / 2.0)
		visual_model.rotation.y = lerp_angle(visual_model.rotation.y, target_rotation, 0.15)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# --- ANIMATION LOGIC ---
	# --- ANIMATION LOGIC ---
	if is_on_floor():
		if was_in_air:
			# Play Jump_end with a 0.1s blend to smooth it out, and 1.8x SPEED to make it snappy
			anim_player.play("Jump_end", 0.1, 1.8)
			
			# TURN OFF PARTICLES
			particles_front1.emitting = false
			particles_back1.emitting = false
			particles_front2.emitting = false
			particles_back2.emitting = false
			
		elif direction and anim_player.current_animation != "Jump_end":
			# Blend into the run smoothly
			anim_player.play("Run", 0.1, 1.5)
			
			# TURN ON PARTICLES!
			particles_front1.emitting = true
			particles_back1.emitting = true
			particles_front2.emitting = true
			particles_back2.emitting = true
			
		elif anim_player.current_animation != "Jump_end" or not anim_player.is_playing():
			anim_player.play("Idle", 0.2)
			
			# TURN OFF PARTICLES
			particles_front1.emitting = false
			particles_back1.emitting = false
			particles_front2.emitting = false
			particles_back2.emitting = false
	else:
		# We are in the air. Are we going up or down?
		if velocity.y > 0:
			# 0.1s blend smooths out the physical takeoff
			anim_player.play("Jump_start", 0.1)
		else:
			# 0.2s blend smooths the harsh transition at the top of the jump before falling
			anim_player.play("Jump_fall", 0.2)
			
		# TURN OFF PARTICLES IN THE AIR
		particles_front1.emitting = false
		particles_back1.emitting = false
		particles_front2.emitting = false
		particles_back2.emitting = false
		
	# Update our air tracking variable for the next frame
	was_in_air = not is_on_floor()

	move_and_slide()
