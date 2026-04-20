class_name SignalTower
extends Node2D

@export var multi_tool_stats: MultiToolStats


func _ready() -> void:
	var collision_shape = $PlaceableZone/CollisionShape2D.shape
	collision_shape.radius = multi_tool_stats.placement_range
