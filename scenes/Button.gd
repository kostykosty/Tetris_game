extends Button

func _on_pressed():
	get_tree().change_scene_to_file("res://scenes/tile_map.tscn")


func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://scenes/управление.tscn")


func _on_button_4_pressed():
	get_tree().change_scene_to_file("res://scenes/сброс_прогресса.tscn")
