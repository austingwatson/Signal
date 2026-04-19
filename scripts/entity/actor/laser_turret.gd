extends Node2D

@onready var detection_component := $DetectionComponent


func _ready() -> void:
	detection_component.disable()


func _on_follow_component_stop_following() -> void:
	modulate = Color.WHITE
	detection_component.enable()
