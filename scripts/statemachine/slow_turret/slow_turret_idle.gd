extends State

@export var turret: Node2D
@export var detection_component: DetectionComponent
@export var turret_animation_component: TurretAnimationComponent
@export var damage: Damage


func enter(_data: Dictionary) -> void:
	turret_animation_component.not_attacking()


func update(_delta: float) -> void:
	var enemies := detection_component.get_all_in_los()
	if enemies.is_empty():
		return
	
	var closest: HurtBox = null
	var dis := INF
	
	for enemy in enemies:
		if enemy.get_parent().get_node("CharacterMovementComponent").slow_per >= damage.slow_per:
			continue
		
		var d := turret.global_position.distance_to(enemy.global_position)
		if d < dis:
			closest = enemy
			dis = d
	
	if closest == null:
		return
	
	statemachine.enter_state("Attack", {"enemy": closest})
