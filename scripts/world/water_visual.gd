extends Node2D

# 海浪可视化 - 在大洪水阶段显示

var water_surface: Line2D
var water_fill: Polygon2D

const SEGMENTS = 50

func _ready():
	visible = false
	
	# 创建水面线条
	water_surface = Line2D.new()
	water_surface.width = 3.0
	water_surface.default_color = Color(0.2, 0.5, 0.8, 0.8)
	add_child(water_surface)
	
	# 创建水面填充
	water_fill = Polygon2D.new()
	water_fill.color = Color(0.1, 0.3, 0.6, 0.6)
	add_child(water_fill)
	
	# 连接信号
	PhaseManager.phase_changed.connect(_on_phase_changed)
	PhaseManager.flood_level_changed.connect(_on_flood_changed)

func _process(_delta):
	if not visible:
		return
	
	_update_water()

func _update_water():
	var screen_width = get_viewport().get_visible_rect().size.x
	var screen_height = get_viewport().get_visible_rect().size.y
	var base_y = screen_height - PhaseManager.get_water_height()
	var time = PhaseManager.wave_time
	
	var points = PackedVector2Array()
	var fill_points = PackedVector2Array()
	
	for i in range(SEGMENTS + 1):
		var x = (float(i) / SEGMENTS) * screen_width
		var wave_offset = PhaseManager.get_wave_offset(x)
		var y = base_y + wave_offset
		points.append(Vector2(x, y))
		fill_points.append(Vector2(x, y))
	
	# 添加底部填充点
	for i in range(SEGMENTS, -1, -1):
		var x = (float(i) / SEGMENTS) * screen_width
		fill_points.append(Vector2(x, screen_height + 50))
	
	water_surface.points = points
	water_fill.polygon = fill_points

func _on_phase_changed(from, to):
	if to == PhaseManager.Phase.DELUGE:
		visible = true
		print("🌊 Water visuals enabled!")
	else:
		visible = false

func _on_flood_changed(level):
	# 可以添加水位变化时的特效
	pass
