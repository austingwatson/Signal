extends State

const threshhold := 0.33
@export var turret: Node2D
@export var damage: Damage
@export var turret_animation_component: TurretAnimationComponent
@export_flags_2d_physics var possible_hits := 0
@export var attack_area: AttackArea
var hits: Array[Area2D] = []


func enter(data: Dictionary) -> void:
	turret_animation_component.attacking()
	
	var enemy: HurtBox = data["enemy"]
	var dir: Vector2 = (enemy.global_position - turret.global_position).normalized()
	turret_animation_component.set_dir(_direction_to_grid(dir))
	
	hits.clear()
	attack_area.rotation = dir.angle()
	attack_area.enable()
	await get_tree().create_timer(0.1).timeout
	hits.sort_custom(func(a, b):
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
	
	var i := 0
	var last_hit: Vector2 = enemy.global_position
	for hit in hits:
		hit.take_damage(damage.damage)
		i += 1
		
		last_hit = hit.global_position
		if i >= damage.max_hits:
			break
	attack_area.disable()
	
	var laser := preload("res://scenes/effect/laser.tscn").instantiate()
	laser.set_laser_points(turret.global_position, last_hit, 4.0)
	EntityManager.add_entity(laser)
	laser.call_deferred("spawn", 0.8)
	
	await get_tree().create_timer(damage.cooldown / 2).timeout
	turret_animation_component.not_attacking()
	await get_tree().create_timer(damage.cooldown / 2).timeout
	if statemachine.current_state.name == "Attack":
		statemachine.enter_state("Idle")
		
	
func get_laser_hits(start: Vector2, end: Vector2) -> Array:
	var space := get_world_2d().direct_space_state
	var shape := SegmentShape2D.new()
	shape.a = start
	shape.b = end
	
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0, Vector2.ZERO)
	params.collide_with_areas = true
	params.collide_with_bodies = false
	params.collision_mask = possible_hits
	
	var hits := space.intersect_shape(params, damage.max_hits)
	var hurt_boxes: Array[HurtBox] = []
	
	for hit in hits:
		if hit["collider"] is HurtBox:
			hurt_boxes.append(hit["collider"])
	
	return hurt_boxes
	

func get_end(hurt_boxes: Array[HurtBox], start: Vector2, end: Vector2) -> Vector2:
	if not hurt_boxes.size() >= damage.max_hits:
		return end
	
	var farthest: HurtBox = null
	var dist := INF
	
	for hurt_box in hurt_boxes:
		var d := start.distance_to(hurt_box.global_position)
		if d < dist:
			farthest = hurt_box
			dist = d
	
	if farthest == null:
		return end
	else:
		return farthest.global_position
	

func _direction_to_grid(dir) -> Vector2i:
	var x := 0
	var y := 0
	
	if abs(dir.x) > threshhold:
		x = sign(dir.x)
	if abs(dir.y) > threshhold:
		y = sign(dir.y)
	
	return Vector2i(x, y)


func _on_attack_area_area_entered(area: Area2D) -> void:
	hits.append(area)
