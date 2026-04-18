class_name Player
extends Node2D

var interactables: Array[InteractableComponent] = []
@onready var build_menu := $BuildMenu
@onready var multi_tool := $MultiTool


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("build"):
		if build_menu.visible:
			build_menu.close()
		else:
			build_menu.open()
	elif Input.is_action_just_pressed("interact"):
		for interactable in interactables:
			interactable.interact()
		interactables.clear()
	elif Input.is_action_just_pressed("ping"):
		multi_tool.ping()


func _on_interact_component_area_entered(area: Area2D) -> void:
	if area is InteractableComponent:
		interactables.append(area)


func _on_interact_component_area_exited(area: Area2D) -> void:
	if area is InteractableComponent:
		interactables.erase(area)
