class_name HordeComponent
extends Node2D

@export var entity: Node2D
@export var path_finder_component: PathFinderComponent


func _ready() -> void:
	var in_horde := entity.is_in_group("horde")
	path_finder_component.use_flowfield = in_horde
	if not in_horde:
		queue_free()


func _on_timer_timeout() -> void:
	entity.queue_free()
