extends Node2D

# 海浪可视化 - 在大洪水阶段显示
# 水覆盖整个游戏世界区域

var water_surface: Line2D
var water_fill: Polygon2D

const SEGMENTS = 100
const WORLD_WIDTH = 2000.0  # 游戏世界宽度
const WORLD_HEIGHT = 1500.0  # 游戏世界高度

func _ready():
	visible = false
	
	# 确保在其他内容之下
	z_index = -100
	
	# 创建水面线条
	water_surface = Line2D.new()
	water_surface.width = 4.0
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
	# 使用固定的世界坐标，而不是屏幕坐标
	var base_y = WORLD_HEIGHT - PhaseManager.get_water_height() - 200  # 从底部开始
	var time = PhaseManager.wave_time
	
	var points = PackedVector2Array()
	var fill_points = PackedVector2Array()
	
	# 覆盖更大的世界区域
	for i in range(SEGMENTS + 1):
		var x = (float(i) / SEGMENTS) * WORLD_WIDTH - 400  # 从世界左侧开始
		var wave_offset = PhaseManager.get_wave_offset(x)
		var y = base_y + wave_offset
		points.append(Vector2(x, y))
		fill_points.append(Vector2(x, y))
	
	# 添加底部填充点
	for i in range(SEGMENTS, -1, -1):
		var x = (float(i) / SEGMENTS) * WORLD_WIDTH - 400
		fill_points.append(Vector2(x, WORLD_HEIGHT + 100))
	
	water_surface.points = points
	water_fill.polygon = fill_points
	
	# 确保水在最底层
	water_fill.z_index = -101
	water_surface.z_index = -100

func _on_phase_changed(from, to):
	if to == PhaseManager.Phase.DELUGE:
		visible = true
		print("🌊 Water visuals enabled!")
	else:
		visible = false

func _on_flood_changed(level):
	pass
