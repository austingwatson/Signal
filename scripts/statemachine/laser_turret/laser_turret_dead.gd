extends State

@export var turret_animation_component: TurretAnimationComponent


func enter(_data: Dictionary) -> void:
	turret_animation_component.dead()
