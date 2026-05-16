extends Node

@onready var animation_player := $AnimationPlayer



func _on_test_level_button_pressed() -> void:
	$ButtonClick.play()
	get_tree().change_scene_to_file("res://scenes/screen/test_level_screen.tscn")


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/screen/game_screen.tscn")


func _on_guide_pressed() -> void:
	$ButtonClick.play()


func _on_play_mouse_entered() -> void:
	$ButtonHover.play()


func _on_guide_mouse_entered() -> void:
	$ButtonHover.play()
