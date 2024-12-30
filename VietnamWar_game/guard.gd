extends CharacterBody3D

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var detection_area : Area3D = $DetectionArea

const SPEED = 5.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")  # Get the gravity from the project settings to be synced with RigidBody nodes.
var dead = false
var is_attacking = false  
var attack_range = 5
var player_in_range = false  # Variable to check if player is in detection range

# Preload the Ammo scene
var AmmoScene = preload("res://ammo.tscn")

func _ready():
	add_to_group("enemy")
	$AnimatedSprite3D.animation_finished.connect(_AnimatedSprite3D_animation_finished)
	$AnimatedSprite3D.play("idle")
	detection_area.connect("body_entered", Callable(self, "_on_detection_area_body_entered"))

func _physics_process(delta):
	if dead or is_attacking:  # Check if the enemy is dead or attacking
		return

	if not player_in_range:  # Only move towards player if they are in detection range
		return

	if player == null:
		return
		
	var dir = player.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()
	
	velocity = dir * SPEED
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	move_and_slide()
	attack()
	

func attack():
	var dist_to_player = global_position.distance_to(player.global_position)
	if dist_to_player > attack_range:
		return
	
	# NEW BLOCK OF CODE TO RE-AIM IF PLAYER MOVES #
	var dir = player.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()
	rotation.y = atan2(dir.x, dir.z)
	# END NEW BLOCK #
	
	is_attacking = true  # Set the attacking flag
	$AnimatedSprite3D.play("shoot")
	
	if $RayCast3D.is_colliding() and $RayCast3D.get_collider().has_method("damage"):
		$RayCast3D.get_collider().damage()
	
	await $AnimatedSprite3D.animation_finished  # Wait for the animation to finish
	is_attacking = false  # Reset the attacking flag


func die():
	dead = true  # Corrected variable scope
	Global.kills += 1
	$AnimatedSprite3D.play("die")
	$CollisionShape3D.disabled = true
	
	# Instantiate and place the ammo
	var ammo_instance = AmmoScene.instantiate()
	ammo_instance.global_position = global_position
	get_parent().add_child(ammo_instance)
	
func _AnimatedSprite3D_animation_finished():
	if not dead:
		$AnimatedSprite3D.play("default")

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true  # Player entered detection range
		if not dead and not is_attacking:
			$AnimatedSprite3D.play("default")

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false  # Player exited detection range
		if not dead:
			$AnimatedSprite3D.play("idle")


