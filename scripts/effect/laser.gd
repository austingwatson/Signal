extends Line2D

func set_laser_points(start_pos: Vector2, end_pos: Vector2, size: float) -> void:
	var points := []
	points.append(start_pos)
	points.append(end_pos)
	self.points = points
	
	width = size
	

func spawn(lifetime: float) -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()
