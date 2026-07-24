extends Node3D

@onready var hinge = $HingePivot
@onready var interact_zone = $Area3D

@onready var door_collision1 = $HingePivot/CollisionShape_door
@onready var door_collision2 = $HingePivot/CollisionShape_door_hinge

var is_open: bool = false
var player_in_zone: bool = false
var target_angle: float = 0.0

# Added just for the print tracker
var last_state: bool = false 

func _ready() -> void:
	interact_zone.body_entered.connect(_on_body_entered)
	interact_zone.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if player_in_zone and Input.is_action_just_pressed("interact"):
		is_open = !is_open
		target_angle = 90.0 if is_open else 0.0
		
		# THE FIX: This perfectly handles both simultaneously. 
		# If is_open is true, disabled becomes true. If false, disabled becomes false.
		door_collision1.set_deferred("disabled", is_open)
		door_collision2.set_deferred("disabled", is_open)

	# The Print Tracker: It will only print when the exact moment the state flips
	if door_collision1.disabled != last_state:
		print("DOOR COLLISIONS DISABLED: ", door_collision1.disabled)
		last_state = door_collision1.disabled

	# The smooth rotation
	hinge.rotation_degrees.y = lerp(hinge.rotation_degrees.y, target_angle, delta * 8.0)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_zone = true

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_zone = false
