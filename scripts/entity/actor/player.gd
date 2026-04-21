class_name Player
extends Node2D

@export var health_resource: HealthResource
var interactables: Array[InteractableComponent] = []
@onready var build_menu := $BuildMenu
@onready var multi_tool := $MultiTool
@onready var statemachine := $StateMachine
@onready var hurtbox := $HurtBox


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("build"):
		if build_menu.visible:
			build_menu.close()
		else:
			build_menu.open()
	elif Input.is_action_just_pressed("interact"):
		for interactable in interactables:
			if is_instance_valid(interactable):
				interactable.interact()
	elif Input.is_action_just_pressed("shoot"):
		$InteractQuiet.play()
	elif Input.is_action_just_pressed("ping"):
		$InteractQuiet.play()
				
	if Input.is_action_pressed("shoot"):
		multi_tool.shoot()
				
	if Input.is_action_pressed("ping"):
		multi_tool.ping()
	else:
		multi_tool.stop_ping()


func _on_interact_component_area_entered(area: Area2D) -> void:
	if area is InteractableComponent:
		interactables.append(area)


func _on_interact_component_area_exited(area: Area2D) -> void:
	if area is InteractableComponent:
		interactables.erase(area)


func _on_hurt_box_hurt(health: int) -> void:
	statemachine.enter_state("Hurt")


func _on_hurt_box_dead() -> void:
	set_process_unhandled_input(false)
	multi_tool.visible = false
	statemachine.enter_state("Knockedout")


func _on_knockedout_back_alive() -> void:
	set_process_unhandled_input(true)
	multi_tool.visible = true
