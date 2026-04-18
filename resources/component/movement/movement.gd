class_name Movement
extends Resource

@export var speed := 0.0
var velocity := Vector2.ZERO


func move(global_position: Vector2, delta: float) -> Vector2:
	global_position += velocity * delta
	return global_position


func set_direction(direction: Vector2) -> void:
	velocity = direction.normalized() * speed
