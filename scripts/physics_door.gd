extends Node3D

@onready var hinge = $HingePivot
@onready var interact_zone = $Area3D
@onready var door_collision1 = $HingePivot/CollisionShape3D
@onready var door_collision2 = $HingePivot/CollisionShape_door_hinge

var is_open: bool = false
var is_moving: bool = false
var player_in_zone: bool = false

func _ready() -> void:
	interact_zone.body_entered.connect(_on_body_entered)
	interact_zone.body_exited.connect(_on_body_exited)

func _input(event: InputEvent) -> void:
	if player_in_zone and event.is_action_pressed("interact") and not is_moving:
		toggle_door()

func toggle_door() -> void:
	is_moving = true
	is_open = !is_open
	
	if is_open:
		door_collision1.set_deferred("disabled", true)
		if door_collision2 != null:
			door_collision2.set_deferred("disabled", true)
	
	var target_angle = 90.0 if is_open else 0.0
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# We are now tweening the AnimatableBody3D directly!
	tween.tween_property(hinge, "rotation:y", deg_to_rad(target_angle), 0.5)
	
	tween.finished.connect(_on_tween_finished)

func _on_tween_finished() -> void:
	is_moving = false 
	
	if not is_open:
		door_collision1.set_deferred("disabled", false)
		if door_collision2 != null:
			door_collision2.set_deferred("disabled", false)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_zone = true

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_zone = false
