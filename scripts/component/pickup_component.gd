class_name PickupComponent
extends Area2D

@export var parent: Node
@export var material_amount: MaterialAmount

func _on_area_entered(area: Area2D) -> void:
	GlobalSignals.call_added_metal(material_amount.metal_amount)
	GlobalSignals.call_added_power_cell(material_amount.power_cell_amount)
	parent.queue_free()
