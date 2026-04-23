extends State

const threshhold := 0.33
@export var turret: Node2D
@export var damage: Damage
@export var turret_animation_component: TurretAnimationComponent


func enter(data: Dictionary) -> void:
	turret_animation_component.attacking()
	
	var enemy: HurtBox = data["enemy"]
	var dir: Vector2 = (enemy.global_position - turret.global_position).normalized()
	turret_animation_component.set_dir(_direction_to_grid(dir))
	
	var laser := preload("res://scenes/effect/slow_laser.tscn").instantiate()
	laser.set_laser_points(turret.global_position, enemy.global_position, 2.0)
	EntityManager.add_entity(laser)
	laser.call_deferred("spawn", 0.2)
	
	var cmc: CharacterMovementComponent = enemy.get_parent().get_node("CharacterMovementComponent")
	cmc.slow_per = damage.slow_per
	
	await get_tree().create_timer(damage.cooldown / 2).timeout
	turret_animation_component.not_attacking()
	await get_tree().create_timer(damage.cooldown / 2).timeout
	if statemachine.current_state.name == "Attack":
		statemachine.enter_state("Idle")
	

func _direction_to_grid(dir) -> Vector2i:
	var x := 0
	var y := 0
	
	if abs(dir.x) > threshhold:
		x = sign(dir.x)
	if abs(dir.y) > threshhold:
		y = sign(dir.y)
	
	return Vector2i(x, y)
