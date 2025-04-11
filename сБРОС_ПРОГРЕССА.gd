extends CanvasLayer



func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")


func _on_button_pressed():
	var config = ConfigFile.new()
	config.set_value("game", "high_score", 0)
	config.save("user://user_data.cfg")
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
