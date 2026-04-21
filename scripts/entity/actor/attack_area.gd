class_name AttackArea
extends Area2D

@export var damage: Damage
@onready var collision_shape := $CollisionShape2D


func _ready() -> void:
	var shape: SegmentShape2D = collision_shape.shape
	shape.b = Vector2(damage.attack_range, 0)
	

func enable() -> void:
	collision_shape.set_deferred("disabled", false)
	

func disable() -> void:
	collision_shape.set_deferred("disabled", true)
