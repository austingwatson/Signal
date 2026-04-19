extends Node


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_screen.tscn")


func _on_test_level_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/test_level_screen.tscn")


func _on_owen_test_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/test_owen_screen.tscn")
