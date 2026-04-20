extends Line2D

@export var flowfield: FlowField
@export var max_points := 100
@export var stop_distance := 1.0
@export var step_size := 32.0


func set_cable_points(start: Vector2, end: Vector2) -> void:
	var pos := start
	var points := []
	points.append(pos)
	
	for i in range(max_points):
		if pos.distance_to(end) <= stop_distance:
			break
		
		var dir := flowfield.get_direction(pos)
		if dir == Vector2.ZERO:
			break
		
		pos += dir.normalized() * step_size
		points.append(pos)
	
	points.append(end)
	self.points = points
