extends Line2D

@export var lifetime := 0.2

func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()
	

func set_lightning_points(start_pos: Vector2, end_pos: Vector2, segments: int, jitter_amount: float) -> void:
	var points := []
	for i in range(segments + 1):
		var t := float(i) / segments
		var pos := start_pos.lerp(end_pos, t)
		
		if i != 0 and i != segments:
			pos += Vector2(
				randf_range(-jitter_amount, jitter_amount), 
				randf_range(-jitter_amount, jitter_amount)
				)
		points.append(pos)
	
	self.points = points
