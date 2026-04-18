class_name InteractableComponent
extends Area2D

signal interacted


func interact() -> void:
	interacted.emit()
