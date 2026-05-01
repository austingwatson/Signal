extends Control

@export var amplitude_scale: float = 20.0
@export var base_frequency: float = 4.0
@export var frequency_boost: float = 6.0
@export var thickness: float = 3.0
@export var wave_color: Color = Color(1, 1, 1, 1)
@export var wave_width: float = 960.0
@export var wave_height: float = 540.0
@export var show_panel := false

var strength_factor := 0.0
var t := 0.0

@onready var panel := $Panel


func _ready() -> void:
	custom_minimum_size = Vector2(wave_width, wave_height)
	panel.visible = show_panel
	
	GlobalSignals.ping_changed.connect(_on_ping_changed)


func _process(delta: float) -> void:
	t += delta
	queue_redraw()
	
	panel.size = custom_minimum_size


func _draw() -> void:
	# Draw relative to this Control's local origin (0,0)
	var w := wave_width
	var h := wave_height * 0.5

	var amplitude := strength_factor * amplitude_scale
	var frequency := base_frequency + strength_factor * frequency_boost

	var last_point := Vector2(0, h)

	for x in range(int(w)):
		var y := h + sin((x * 0.03) * frequency + t * frequency) * amplitude
		var point := Vector2(x, y)
		draw_line(last_point, point, wave_color, thickness)
		last_point = point


func _on_ping_changed(distance: float, angle: float) -> void:
	var angle_weight := 0.25
	var angle_mod = lerp(1.0, angle, angle_weight)
	strength_factor = distance * angle_mod
