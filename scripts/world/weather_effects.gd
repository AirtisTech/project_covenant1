extends Node2D

# 天气效果系统 - 暴风雨、闪电、雨滴

var rain_particles: CPUParticles2D
var storm_darkness: ColorRect
var lightning_timer: float = 0.0
var lightning_active: bool = false

const RAIN_INTENSITY = 100  # 雨滴数量

func _ready():
	_setup_rain()
	_setup_darkness()
	visible = false
	
	# 连接信号
	PhaseManager.phase_changed.connect(_on_phase_changed)
	PhaseManager.weather_intensity_changed.connect(_on_weather_changed)

func _setup_rain():
	rain_particles = CPUParticles2D.new()
	rain_particles.emitting = true  # 默认启用
	rain_particles.amount = 200  # 增加雨滴数量
	rain_particles.lifetime = 1.0
	rain_particles.direction = Vector2(0.2, 1)  # 稍微倾斜
	rain_particles.spread = 5.0
	rain_particles.gravity = Vector2(0, 1500)  # 下落更快
	rain_particles.initial_velocity_min = 800.0
	rain_particles.initial_velocity_max = 1200.0
	rain_particles.scale_amount_min = 1.0
	rain_particles.scale_amount_max = 3.0
	rain_particles.color = Color(0.7, 0.8, 0.9, 0.5)
	# 使用发射区域覆盖整个屏幕
	rain_particles.position = Vector2(640, 360)
	rain_particles.amount = 500
	# 设置发射形状为矩形区域
	rain_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	rain_particles.emission_rect_extents = Vector2(800, 50)
	add_child(rain_particles)

func _setup_darkness():
	storm_darkness = ColorRect.new()
	storm_darkness.color = Color(0, 0, 0, 0)
	storm_darkness.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(storm_darkness)

func _process(delta):
	if not visible:
		return
	
	var pm = PhaseManager
	
	# 始终显示雨滴效果
	if rain_particles:
		# 跟随相机
		var camera = get_viewport().get_camera_2d()
		if camera:
			rain_particles.position = camera.global_position + Vector2(640, 360)
		
		# 根据暴风雨强度调整
		if pm.is_storming:
			rain_particles.emitting = true
			rain_particles.amount = int(300 * pm.weather_intensity)
		else:
			rain_particles.emitting = true
			rain_particles.amount = 100
	
	# 闪电效果
	if pm.is_storming and randf() < 0.002:  # 小概率闪电
		_trigger_lightning()
	
	# 更新黑暗程度
	if storm_darkness:
		var target_alpha = 0.0
		if pm.is_storming:
			target_alpha = pm.weather_intensity * 0.4
		storm_darkness.color.a = lerp(storm_darkness.color.a, target_alpha, delta * 2)

func _trigger_lightning():
	lightning_active = true
	lightning_timer = 0.1
	
	# 瞬间变亮
	if storm_darkness:
		storm_darkness.color.a = 0.0
	
	# 闪电后跟随雷声（随机延迟）
	await get_tree().create_timer(randf_range(0.5, 2.0)).timeout
	if PhaseManager.is_storming:
		_play_thunder_sound()
	
	lightning_active = false

func _play_thunder_sound():
	# 可以在这里添加雷声效果
	# 目前先用控制台输出模拟
	print("⚡ 雷声！")

func _on_phase_changed(from, to):
	if to == PhaseManager.Phase.DELUGE or to == PhaseManager.Phase.DRIFT:
		visible = true
		print("🌧️ 天气系统启用")
	else:
		visible = false
		if rain_particles:
			rain_particles.emitting = false

func _on_weather_changed(intensity: float):
	if rain_particles:
		rain_particles.emitting = intensity > 0.3
		rain_particles.amount = int(RAIN_INTENSITY * intensity)

func get_weather_description() -> String:
	var pm = PhaseManager
	if not pm.is_storming:
		return "☀️ 晴朗"
	elif pm.weather_intensity < 0.3:
		return "🌤️ 多云"
	elif pm.weather_intensity < 0.6:
		return "🌧️ 小雨"
	elif pm.weather_intensity < 0.8:
		return "🌧️ 大雨"
	else:
		return "⛈️ 暴风雨！"
