extends State

@export var path_finder_component: PathFinderComponent
@export var detection_component: DetectionComponent
@export var character_movement_component: CharacterMovementComponent


func update(_delta: float) -> void:
	var closest := detection_component.get_closest()
	if closest != null:
		character_movement_component.set_direction(Vector2.ZERO)
		statemachine.enter_state("Attack", {"target": closest})
	else:
		path_finder_component.path_find()
