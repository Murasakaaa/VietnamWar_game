extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	Level1Music.play_music_level()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://level_2.tscn")
		Global.current_level = 2
		Level1Music.stop()
