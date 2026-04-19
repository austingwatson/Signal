extends State

@export var detection_component: DetectionComponent


func update(_delta: float) -> void:
	var closest := detection_component.get_closest()
	if closest == null:
		return
	statemachine.enter_state("Attack", {"enemy": closest})
