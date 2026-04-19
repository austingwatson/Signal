class_name CharacterMovementComponent
extends Node2D

@export var character: CharacterBody2D
@export var movement_resource: MovementResource
var direction := Vector2.ZERO


func _physics_process(_delta: float) -> void:
	character.move_and_slide()


func set_direction(direction: Vector2) -> void:
	self.direction = direction
	character.velocity = direction.normalized() * movement_resource.speed
