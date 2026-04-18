class_name PlayerInteractionComponent
extends Area2D

var interactable_component: InteractableComponent = null


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and interactable_component != null:
		interactable_component.interacted.emit()


func _on_area_entered(area: Area2D) -> void:
	if area is InteractableComponent:
		interactable_component = area


func _on_area_exited(area: Area2D) -> void:
	if area is InteractableComponent:
		interactable_component = null
