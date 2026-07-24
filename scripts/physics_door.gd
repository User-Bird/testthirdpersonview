extends Node3D

@onready var hinge = $HingePivot
@onready var interact_zone = $Area3D

@onready var door_collision1 = $HingePivot/Door/CollisionShape3D
@onready var door_collision2 = $HingePivot/Door/CollisionShape3D2 

var is_open: bool = false
var is_moving: bool = false
var player_node: Node3D = null

func _ready() -> void:
	interact_zone.body_entered.connect(_on_body_entered)
	interact_zone.body_exited.connect(_on_body_exited)

func _input(event: InputEvent) -> void:
	if player_node != null and event.is_action_pressed("interact") and not is_moving:
		toggle_door()

func toggle_door() -> void:
	is_moving = true
	is_open = !is_open
	
	# THE FIX: Use set_deferred so the physics engine doesn't crash the script
	if is_open:
		door_collision1.set_deferred("disabled", true)
		if door_collision2 != null:
			door_collision2.set_deferred("disabled", true)
	
	var swing_angle = 0.0
	
	if is_open:
		var direction_to_player = player_node.global_position - global_position
		var door_forward = global_transform.basis.z
		
		# THE FIX: Swapped the 90 and -90 so it pushes AWAY from the player
		if direction_to_player.dot(door_forward) > 0:
			swing_angle = -90.0 
		else:
			swing_angle = 90.0  
	else:
		swing_angle = 0.0 
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# THE FIX: Tweening the full Vector3 is much safer for the engine parser
	tween.tween_property(hinge, "rotation_degrees", Vector3(0, swing_angle, 0), 0.5)
	
	tween.finished.connect(_on_tween_finished)

func _on_tween_finished() -> void:
	is_moving = false 
	
	if not is_open:
		# Safely re-enable collisions
		door_collision1.set_deferred("disabled", false)
		if door_collision2 != null:
			door_collision2.set_deferred("disabled", false)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player_node = body 

func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		player_node = null
