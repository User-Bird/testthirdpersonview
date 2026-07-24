extends Node3D

@onready var hinge = $HingePivot
@onready var interact_zone = $Area3D

@onready var door_collision1 = $HingePivot/CollisionShape_door
@onready var door_collision2 = $HingePivot/CollisionShape_door_knob

var is_open: bool = false
var player_in_zone: bool = false
var target_angle: float = 0.0

# Timer used to control how often the debug prints
var debug_timer: float = 0.0 

func _ready() -> void:
	interact_zone.body_entered.connect(_on_body_entered)
	interact_zone.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if player_in_zone and Input.is_action_just_pressed("interact"):
		is_open = !is_open
		target_angle = 90.0 if is_open else 0.0
		
		# 1. Disable IMMEDIATELY when opening
		if is_open:
			door_collision1.set_deferred("disabled", true)
			if door_collision2 != null:
				door_collision2.set_deferred("disabled", true)

	# 2. Smooth rotation (overrides physics snapping)
	hinge.rotation_degrees.y = lerp(hinge.rotation_degrees.y, target_angle, delta * 8.0)
	
	# 3. Re-enable ONLY when fully closed (angle is less than 2 degrees)
	if not is_open and hinge.rotation_degrees.y < 2.0:
		door_collision1.set_deferred("disabled", false)
		if door_collision2 != null:
			door_collision2.set_deferred("disabled", false)

	# 4. Print tracker (Runs exactly every 0.5 seconds)
	debug_timer += delta
	if debug_timer >= 0.5:
		var knob_disabled = "NULL"
		if door_collision2 != null:
			knob_disabled = str(door_collision2.disabled)
			
		print("DOOR DISABLED: ", door_collision1.disabled, " | KNOB DISABLED: ", knob_disabled)
		
		# Reset the timer
		debug_timer = 0.0

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_zone = true

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_zone = false
