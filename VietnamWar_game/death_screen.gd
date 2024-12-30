extends Control



func _on_play_pressed():
	get_tree().change_scene_to_file("res://level_1.tscn")
	Global.ammo = 10
	Global.kills = 0

func _on_quit_pressed():
	get_tree().quit()
