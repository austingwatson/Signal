class_name PickupComponent
extends Area2D

@export var parent: Node
@export var material_amount: MaterialAmount
@onready var pickup_sound := $PickupSound

func _on_area_entered(area: Area2D) -> void:
	GlobalSignals.call_added_metal(material_amount.metal_amount)
	GlobalSignals.call_added_power_cell(material_amount.power_cell_amount)
	pickup_sound.play()
	area_entered.disconnect(_on_area_entered)
	parent.visible = false


func _on_pickup_sound_finished() -> void:
	parent.queue_free()
