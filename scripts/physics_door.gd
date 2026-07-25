extends Node3D

@onready var hinge = $HingePivot
@onready var interact_zone = $Area3D

var is_open: bool = false
var player_in_zone: bool = false

func _ready() -> void:
	# Connect the Area3D signals to detect when the player is near
	interact_zone.body_entered.connect(_on_body_entered)
	interact_zone.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	# Toggle the door state if the player is in range and presses the interact key
	if player_in_zone and Input.is_action_just_pressed("interact"):
		is_open = !is_open
		
	# Set the target angle (90 degrees if open, 0 if closed)
	var target_angle = 90.0 if is_open else 0.0
	
	# Smoothly swing the door to the target angle
	hinge.rotation_degrees.y = lerp(hinge.rotation_degrees.y, target_angle, delta * 8.0)

func _on_body_entered(body: Node3D) -> void:
	# Check if the object entering the zone is the player
	if body is CharacterBody3D:
		player_in_zone = true

func _on_body_exited(body: Node3D) -> void:
	# Check if the player left the zone
	if body is CharacterBody3D:
		player_in_zone = false
