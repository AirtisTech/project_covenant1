extends Node

enum Phase { LAYOUT, DELUGE, DRIFT }
var current_phase: Phase = Phase.LAYOUT

var day: int = 1
var time_of_day: float = 0.0
const DAY_DURATION = 60.0

# 数据指标
var veg_rations: float = 2000.0
var meat_rations: float = 500.0
var faith: float = 100.0
var ship_stability: float = 100.0
var weight_distribution: float = 0.0
var ark_system: Node2D = null

signal stats_updated()
signal phase_started(new_phase: Phase)

func _ready():
	print("--- 圣约计划启动 ---")

func start_deluge_phase():
	current_phase = Phase.DELUGE
	phase_started.emit(current_phase)
	print("--- 洪水爆发：进入大洪水阶段 ---")
	
	# 布局锁定，开启生存循环
	stats_updated.emit()

func update_ark_stats(s: float, d: float):
	ship_stability = clamp(s, 0.0, 100.0)
	weight_distribution = clamp(d, -1.0, 1.0)
	stats_updated.emit()

func consume_faith(amount: float) -> bool:
	if faith >= amount:
		faith = faith - amount
		stats_updated.emit()
		return true
	return false

func add_faith(amount: float):
	faith = clamp(faith + amount, 0.0, 100.0)
	stats_updated.emit()

func _process(delta):
	# 只有非布局阶段才走时间
	if current_phase != Phase.LAYOUT:
		_update_time(delta)

func _update_time(delta):
	time_of_day = time_of_day + (delta / DAY_DURATION)
	if time_of_day >= 1.0:
		time_of_day = 0.0
		day = day + 1
		_consume_daily_rations()

func _consume_daily_rations():
	# 结算逻辑
	veg_rations = veg_rations - 100.0 # 模拟一家人的基础消耗
	if veg_rations < 0: veg_rations = 0
	stats_updated.emit()
