extends State

@export var damage: Damage
@export var animated_sprite: AnimatedSprite2D
@export var detection_component: DetectionComponent
@export var alert_detection: DetectionComponent
@onready var timer := $Timer
var alert: HurtBox = null


func enter(_data: Dictionary) -> void:
	animated_sprite.play("alert")
	timer.start(damage.alert_timer)
	

func update(_delta: float) -> void:
	var closest = detection_component.get_closest()
	if closest != null:
		timer.stop()
		statemachine.enter_state("Idle")
	alert = alert_detection.get_closest()


func _on_timer_timeout() -> void:
	timer.stop()
	if alert == null:
		statemachine.enter_state("Sleep")
	else:
		statemachine.enter_state("Idle")
