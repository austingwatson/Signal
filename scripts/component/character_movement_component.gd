class_name CharacterMovementComponent
extends Node2D

@export var character: CharacterBody2D
@export var movement_resource: MovementResource
var direction := Vector2.ZERO
var velocity := Vector2.ZERO
var slow_per := 0.0


func _physics_process(_delta: float) -> void:
	character.velocity = velocity * (1.0 - slow_per)
	character.move_and_slide()


func set_direction(direction: Vector2) -> void:
	self.direction = direction
	velocity = direction.normalized() * movement_resource.speed
