extends CanvasLayer

var time_since_last_shot = 0.0
var fire_rate = 1.0
var can_shoot = true

func _ready():
	$AnimatedSprite2D.animation_finished.connect(_on_AnimatedSprite2D_animation_finished)
	$AnimatedSprite2D.play(Global.current_weapon + "_idle")
	

func _process(delta):
	time_since_last_shot += delta
	can_shoot = time_since_last_shot >= (1.0 / fire_rate)
	
	if Global.current_weapon != "knife" and Global.ammo <= 0:
		Global.current_weapon = "knife"
		$AnimatedSprite2D.play("knife_idle")
	
	if Input.is_action_pressed("Attack") and can_shoot:
		
		if Global.current_weapon == "knife":
			$AnimatedSprite2D.play("london_stab")
		else:
			$AnimatedSprite2D.play(Global.current_weapon + "_shoot")
			
		time_since_last_shot = 0.0
		
		if Global.current_weapon != "knife":
			if Global.ammo > 0:
				Global.ammo -= 1
				
	match Global.current_weapon:
		"gun":
			fire_rate = 3.0
		"machine":
			fire_rate = 6.0
		"mini":
			fire_rate = 10.0
		"knife":
			fire_rate = 2.0
		_:
			fire_rate = 1.0
			
			
func select_gun():
	if Input.is_action_pressed("premiere_arme") and Global.ammo > 0:
		Global.current_weapon = "gun"
		$AnimatedSprite2D.play("gun_idle")
	
func select_knife():
	if Input.is_action_pressed("seconde_arme"):
		Global.current_weapon = "knife"
		$AnimatedSprite2D.play("knife_idle")
		

func _on_AnimatedSprite2D_animation_finished():
	$AnimatedSprite2D.play(Global.current_weapon + "_idle")
	select_gun()
	select_knife()
	update_player_health() 
	update_player_ammo()
	update_player_lives()
	update_face_animation(get_parent().player_health)
	update_player_level()
	update_player_kills()

func update_player_health():
	$Health.text=str(get_parent().player_health)
	
func update_player_level():
	$Levels.text=str(Global.current_level)
	
func update_player_kills():
	$Kills.text=str(Global.kills)
	
func update_player_ammo():
	$Ammo.text=str(Global.ammo)

func update_player_lives():
	$Lives.text=str(Global.lives)

func update_face_animation(health):
	var animation_name = ""
	if health > 90:
		animation_name = "100"
	elif health > 75:
		animation_name = "90"
	elif health > 60:
		animation_name = "75"
	elif health > 45:
		animation_name = "60"
	elif health > 30:
		animation_name = "45"
	elif health > 15:
		animation_name = "30"
	else:
		animation_name = "15"
	
	$bj.play(animation_name)
