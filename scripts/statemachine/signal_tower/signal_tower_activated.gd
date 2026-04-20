extends State

@export var sprite: Sprite2D
var next := 1


func enter(_data: Dictionary) -> void:
	sprite.frame = 3
	$Timer.start()
	


func _on_timer_timeout() -> void:
	sprite.frame += next
	next *= -1
