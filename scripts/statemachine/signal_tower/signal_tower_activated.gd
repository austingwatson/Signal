extends State

@export var tower: Node
@export var sprite: Sprite2D
@export var collision_shape: CollisionShape2D
@export var hurt_box_shape: CollisionShape2D
var next := 1


func enter(_data: Dictionary) -> void:
	sprite.frame = 3
	$Timer.start()
	collision_shape.set_deferred("disabled", false)
	hurt_box_shape.set_deferred("disabled", false)
	tower.add_to_group("tower_on")


func _on_timer_timeout() -> void:
	sprite.frame += next
	next *= -1


func _on_hurt_box_dead() -> void:
	$Timer.stop()
	statemachine.enter_state("Destroyed")
