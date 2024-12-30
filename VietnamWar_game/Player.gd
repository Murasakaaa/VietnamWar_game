extends CharacterBody3D

@onready var head = $head
@onready var debout = $debout
@onready var accroupi = $accroupi
@onready var ray_cast_3d = $RayCast3D
# speed vars
@onready var ui_script = $ui
@onready var ray = $head/Camera3D/RayCast3D

const crouching_speed = 3
var current_speed = 5.0
const TURN_SPEED = .05
const walking_speed = 5.0
var player_health = 100
# Moves vars

const JUMP_VELOCITY = 4.5
var lerp_speed = 10.0
var crouching_depth = -.5

# input vars

const mouse_sens = 0.2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")
	
func _input(event):
	# mouvement de souris gauche droite
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))


func _process(delta):
	# pour quitter le jeu
	if Input.is_action_just_pressed("quit"):
		Level1Music.stop()
		get_tree().change_scene_to_file("res://menu.tscn")
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# pour s'accroupir
	if Input.is_action_pressed("crouch"):
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y,1.5 + crouching_depth, delta * lerp_speed)
		debout.disabled = true
		accroupi.disabled = false
	elif !ray_cast_3d.is_colliding():
		debout.disabled = false
		accroupi.disabled = true
		head.position.y = lerp(head.position.y,1.5, delta * lerp_speed)
		current_speed = walking_speed
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	if Input.is_action_pressed("turn_head_left"):
		self.rotate_y(TURN_SPEED)
	if Input.is_action_pressed("turn_head_right"):
		self.rotate_y(-TURN_SPEED)

	if Input.is_action_pressed("Attack"):
		if ui_script.can_shoot:
			shoot()
	
	move_and_slide()
	
func shoot():
	var sound_player = $AudioStreamPlayer3D
	match  Global.current_weapon:
		"gun":
			sound_player.stream = preload("res://Assets/gun.ogg")
		
		"knife":
			sound_player.stream = preload("res://Assets/slashkut-108175.mp3")
	
	sound_player.play()
	
	if ray.is_colliding() and ray.get_collider().has_method("die"):
		ray.get_collider().die()
	
	
func damage():
	player_health -= 5
	print(player_health)
	if player_health <= 0:
		if Global.lives <= 1:
			get_tree().change_scene_to_file("res://death_screen.tscn")
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		else:
			Global.lives -= 1
			if Global.current_level == 1:
				get_tree().change_scene_to_file("res://level_1.tscn")
				Global.ammo = 10
			elif Global.current_level == 2:
				get_tree().change_scene_to_file("res://level_2.tscn")
				Global.ammo = 10
			elif Global.current_level == 3:
				get_tree().change_scene_to_file("res://level_3.tscn")
				Global.ammo = 10

