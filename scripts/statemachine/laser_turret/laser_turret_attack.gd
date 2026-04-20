extends State

const threshhold := 0.33
@export var turret: Node2D
@export var damage: Damage
@export var turret_animation_component: TurretAnimationComponent


func enter(data: Dictionary) -> void:
	turret_animation_component.attacking()
	
	var dir: Vector2 = (data["enemy"].global_position - turret.global_position).normalized()
	turret_animation_component.set_dir(_direction_to_grid(dir))
	
	data["enemy"].take_damage(damage.damage)
	await get_tree().create_timer(damage.cooldown).timeout
	statemachine.enter_state("Idle")
	

func _direction_to_grid(dir) -> Vector2i:
	var x := 0
	var y := 0
	
	if abs(dir.x) > threshhold:
		x = sign(dir.x)
	if abs(dir.y) > threshhold:
		y = sign(dir.y)
	
	return Vector2i(x, y)
