class_name MovementComponent
extends Node2D

@export var entity: Node2D
@export var movement_resource: MovementResource
var velocity := Vector2.ZERO


func _physics_process(delta: float) -> void:
	entity.global_position += velocity * delta
	

func set_direction(direction: Vector2) -> void:
	velocity = direction.normalized() * movement_resource.speed
