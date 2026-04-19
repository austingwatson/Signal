class_name FollowComponent
extends Node2D

signal stop_following

@export var parent: Node2D
@export var offset := Vector2.ZERO
var entity: Node2D = null


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot"):
		stop_following.emit()
		queue_free()


func _physics_process(delta: float) -> void:
	if entity == null:
		return
		
	parent.global_position = entity.global_position + offset.rotated(entity.global_rotation)


func follow(entity: Node2D) -> void:
	self.entity = entity
