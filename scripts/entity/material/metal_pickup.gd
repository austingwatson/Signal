class_name MetalPickup
extends Node2D

@export var material_amount: MaterialAmount


func _on_interactable_component_interacted() -> void:
	GlobalSignals.call_added_metal(material_amount.amount)
	queue_free()
