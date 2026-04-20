extends Node2D

@export var amplitude_scale: float = 20.0      # Max vertical movement
@export var base_frequency: float = 4.0        # Base speed of wave
@export var frequency_boost: float = 6.0       # Extra speed from strength
@export var thickness: float = 3.0             # Line thickness
@export var wave_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var width := 960.0
@export var height := 540.0
@export var margin := Vector2(10, -50)

var strength_factor := 0.0
var t := 0.0


func _ready() -> void:
	GlobalSignals.ping_changed.connect(_on_ping_changed)
	

func _process(delta: float) -> void:
	t += delta
	
	var cam = get_viewport().get_camera_2d()
	var size = get_viewport_rect().size
	if cam:
		global_position = cam.get_screen_center_position() + Vector2(-size.x / 2, size.y / 2) + margin
	
	queue_redraw()
	

func _draw() -> void:
	var w := width
	var h := height * 0.5
	
	# Amplitude + frequency driven by combined strength
	var amplitude := strength_factor * amplitude_scale
	var frequency := base_frequency + strength_factor * frequency_boost

	var last_point := Vector2(0, h)

	for x in range(int(w)):
		var y := h + sin((x * 0.03) * frequency + t * frequency) * amplitude
		var point := Vector2(x, y)
		draw_line(last_point, point, wave_color, thickness)
		last_point = point
	

func _on_ping_changed(distance: float, angle: float) -> void:
	# Distance dominates, angle is a secondary modifier
	# Angle can boost the signal by up to +25%
	var angle_weight := 0.25
	var angle_mod = lerp(1.0, angle, angle_weight)
	
	strength_factor = distance * angle_mod
