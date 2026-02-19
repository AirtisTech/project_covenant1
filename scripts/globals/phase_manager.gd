extends Node

# 游戏阶段管理器
enum Phase { PREPARATION, DELUGE, DRIFT }

var current_phase: Phase = Phase.PREPARATION
var current_day: int = 1
var phase_days: Dictionary = {
	Phase.PREPARATION: 7,
	Phase.DELUGE: 40,
	Phase.DRIFT: 150
}

# 大洪水参数
var flood_water_level: float = 0.0  # 0-1 水位
var flood_speed: float = 0.0        # 水位上升速度
var ark_tilt: float = 0.0          # -1 到 1 左右倾斜
var ark_roll: float = 0.0          # 前后倾斜

# 海浪参数
var wave_time: float = 0.0
var wave_amplitude: float = 10.0   # 海浪高度
var wave_frequency: float = 1.0    # 海浪频率

# 天气
var weather_intensity: float = 0.0  # 0-1 暴风雨强度
var is_storming: bool = false

signal phase_changed(from: Phase, to: Phase)
signal day_changed(day: int)
signal flood_level_changed(level: float)
signal ark_tilt_changed(tilt: float)

func _ready():
	print("📅 Phase: Preparation Day 1/7")

func advance_day():
	current_day += 1
	day_changed.emit(current_day)
	
	# 处理动物生存（每天）
	var survival = get_node_or_null("/root/AnimalSurvival")
	if survival:
		survival.process_daily()
	
	# 检查阶段转换
	var days_in_phase = phase_days[current_phase]
	if current_day > days_in_phase:
		_change_to_next_phase()
	else:
		print("📅 Day ", current_day, "/", days_in_phase)

func _change_to_next_phase():
	var old_phase = current_phase
	
	match current_phase:
		Phase.PREPARATION:
			current_phase = Phase.DELUGE
			current_day = 1
			_start_flood()
		Phase.DELUGE:
			current_phase = Phase.DRIFT
			current_day = 1
			_start_drift()
		Phase.DRIFT:
			# 游戏结束或循环
			print("🎉 Game Complete!")
	
	phase_changed.emit(old_phase, current_phase)
	print("🔄 Phase changed to: ", _get_phase_name())

func _get_phase_name() -> String:
	match current_phase:
		Phase.PREPARATION: return "Preparation"
		Phase.DELUGE: return "Deluge"
		Phase.DRIFT: return "Drift"
		_: return "Unknown"

func _start_flood():
	print("🌊 FLOOD BEGINS! 40 days of survival...")
	# 洪水直接淹没，无需慢慢上升
	flood_water_level = 1.0
	flood_speed = 0.0
	# 立即触发水位变化信号
	flood_level_changed.emit(flood_water_level)

func _start_drift():
	print("🛶 Entering Drift phase - 150 days to find land...")
	flood_water_level = 1.0
	is_storming = false

func _process(delta):
	if current_phase == Phase.DELUGE:
		# 洪水已直接满，不需要更新水位
		_update_waves(delta)
		_update_weather(delta)
		_apply_ark_motion(delta)

func _update_flood(delta):
	# 水位上升
	flood_water_level = min(flood_water_level + flood_speed * delta, 1.0)
	flood_level_changed.emit(flood_water_level)

func _update_waves(delta):
	wave_time += delta * wave_frequency
	# 简单的正弦波

func _update_weather(delta):
	# 随机暴风雨
	if randf() < 0.001:  # 小概率触发
		is_storming = !is_storming
		weather_intensity = randf() * 0.5 + 0.5 if is_storming else 0.0

func _apply_ark_motion(delta):
	# 只有当水位上升到一定程度时才摇晃（船在水中）
	# 假设水位超过30%时船开始摇晃
	var water_threshold = 0.3
	
	if flood_water_level < water_threshold:
		# 水位还没到，停止摇晃
		ark_tilt = lerp(ark_tilt, 0.0, delta * 2.0)
		ark_roll = lerp(ark_roll, 0.0, delta * 2.0)
		ark_tilt_changed.emit(ark_tilt)
		return
	
	# 基于海浪和天气计算方舟摇晃
	var target_tilt = 0.0
	var target_roll = 0.0
	
	if is_storming:
		target_tilt = sin(wave_time * 2.0) * 0.15 * weather_intensity
		target_roll = cos(wave_time * 1.5) * 0.1 * weather_intensity
	
	# 平滑过渡
	ark_tilt = lerp(ark_tilt, target_tilt, delta * 2.0)
	ark_roll = lerp(ark_roll, target_roll, delta * 2.0)
	
	ark_tilt_changed.emit(ark_tilt)

func get_water_height() -> float:
	# 返回当前水位高度（像素）
	# 方舟甲板在 Y=300-380，水位要超过 1100 才能淹没
	return flood_water_level * 1200.0

func get_wave_offset(x: float) -> float:
	# 获取指定x位置的波浪偏移
	if current_phase == Phase.PREPARATION:
		return 0.0
	return sin(wave_time + x * 0.01) * wave_amplitude * (1.0 + weather_intensity)
