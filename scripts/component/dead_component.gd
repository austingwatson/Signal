class_name DeadComponent
extends Node2D

@export var node_to_remove: Node
@export var hurt_box: HurtBox
@export var health_resource: HealthResource
@export var state_machine: StateMachine
@export var animated_sprite: AnimatedSprite2D
@export var collisions: Array[Node] = []


func _ready() -> void:
	hurt_box.dead.connect(_on_dead)
	

func _on_dead() -> void:
	hurt_box.dead.disconnect(_on_dead)
	state_machine.enter_state("Dead")
	animated_sprite.play("dead")
	
	for collision in collisions:
		collision.get_node("CollisionShape2D").set_deferred("disabled", true)
	
	await get_tree().create_timer(health_resource.dead_body_timer).timeout
	node_to_remove.queue_free()
