extends State

@export var animated_sprite: AnimatedSprite2D
@export var alert_detection: DetectionComponent


func enter(_data: Dictionary) -> void:
	animated_sprite.play("sleep")
	

func update(_delta: float) -> void:
	var closest: HurtBox = alert_detection.get_closest()
	if closest != null:
		statemachine.enter_state("Alerted")
