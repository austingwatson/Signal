extends State

@export var character_movement_component: CharacterMovementComponent


func update(_delta: float) -> void:
	character_movement_component.set_direction(Vector2.ZERO)
