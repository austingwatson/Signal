class_name TurretDeadComponent
extends Node2D

@export var hurt_box: HurtBox
@export var state_machine: StateMachine
@export var collisions: Array[Node] = []


func _ready() -> void:
	hurt_box.dead.connect(_on_dead)
	

func _on_dead() -> void:
	hurt_box.dead.disconnect(_on_dead)
	
	for collision in collisions:
		collision.get_node("CollisionShape2D").set_deferred("disabled", true)
	
	await get_tree().create_timer(0.1).timeout
	state_machine.enter_state("Dead")
