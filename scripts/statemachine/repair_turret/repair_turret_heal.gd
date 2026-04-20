extends State

const threshhold := 0.33
@export var turret: Node2D
@export var damage: Damage
@export var turret_animation_component: TurretAnimationComponent


func enter(data: Dictionary) -> void:
	var friend: HurtBox = data["friend"]
	
	turret_animation_component.attacking()
	var dir: Vector2 = (friend.global_position - turret.global_position).normalized()
	turret_animation_component.set_dir(_direction_to_grid(dir))
	
	var heal_laser := preload("res://scenes/effect/heal_laser.tscn").instantiate()
	heal_laser.set_laser_points(turret.global_position, friend.global_position, 1.0)
	EntityManager.add_entity(heal_laser)
	heal_laser.call_deferred("spawn", 0.2)
	
	friend.heal(damage.damage)
	
	await get_tree().create_timer(damage.cooldown / 2).timeout
	turret_animation_component.not_attacking()
	await get_tree().create_timer(damage.cooldown / 2).timeout
	if statemachine.current_state.name == "Heal":
		statemachine.enter_state("Idle")
	

func _direction_to_grid(dir) -> Vector2i:
	var x := 0
	var y := 0
	
	if abs(dir.x) > threshhold:
		x = sign(dir.x)
	if abs(dir.y) > threshhold:
		y = sign(dir.y)
	
	return Vector2i(x, y)
