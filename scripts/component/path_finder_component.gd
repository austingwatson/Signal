class_name PathFinderComponent
extends Node2D

@export var character_movement_component: CharacterMovementComponent

var flow_field: FlowField = preload("res://scripts/map/flow_field.tres")
var use_flowfield := true


func _physics_process(_delta: float) -> void:
	if use_flowfield:
		var dir := flow_field.get_direction(global_position)
		character_movement_component.set_direction(dir)
	else:
		pass
