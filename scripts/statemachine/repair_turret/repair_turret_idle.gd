extends State

@export var detection_component: DetectionComponent
@export var turret_animation_component: TurretAnimationComponent


func enter(_data: Dictionary) -> void:
	turret_animation_component.not_attacking()


func update(_delta: float) -> void:
	var closest := detection_component.get_closest()
	if closest == null:
		return
	if closest.at_max_health():
		return
		
	statemachine.enter_state("Heal", {"friend": closest})
