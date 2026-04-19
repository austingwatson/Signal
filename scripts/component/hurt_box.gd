class_name HurtBox
extends Area2D

signal hurt(health: int)
signal dead

@export var health_resource: HealthResource
@onready var health := health_resource.max_health


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		dead.emit()
	else:
		hurt.emit(health)
