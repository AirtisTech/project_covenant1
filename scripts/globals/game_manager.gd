extends Node

enum Phase { LAYOUT, DELUGE, DRIFT }
var current_phase: Phase = Phase.LAYOUT

var day: int = 1
var time_of_day: float = 0.0
const DAY_DURATION = 60.0

# 数据指标
var veg_rations: float = 2000.0
var meat_rations: float = 500.0
var water: float = 2000.0  # 新增水源
var faith: float = 100.0
var ship_stability: float = 100.0
var weight_distribution: float = 0.0
var ark_system: Node2D = null

# 生存状态
var humans_alive: int = 8
var animals_alive: int = 0

signal stats_updated()
signal phase_started(new_phase: Phase)
signal resource_changed(resource: String, amount: float)
signal survival_event(message: String)

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

func consume_resource(resource: String, amount: float) -> bool:
	match resource:
		"veg":
			if veg_rations >= amount:
				veg_rations -= amount
				resource_changed.emit("veg", -amount)
				return true
		"meat":
			if meat_rations >= amount:
				meat_rations -= amount
				resource_changed.emit("meat", -amount)
				return true
		"water":
			if water >= amount:
				water -= amount
				resource_changed.emit("water", -amount)
				return true
	return false

func add_resource(resource: String, amount: float):
	match resource:
		"veg":
			veg_rations += amount
			resource_changed.emit("veg", amount)
		"meat":
			meat_rations += amount
			resource_changed.emit("meat", amount)
		"water":
			water += amount
			resource_changed.emit("water", amount)
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
		_process_daily_survival()

func _process_daily_survival():
	# 家人每天消耗
	var human_food_need = humans_alive * 10.0  # 每人10单位食物
	var human_water_need = humans_alive * 15.0  # 每人15单位水
	
	# 尝试消耗食物
	if veg_rations >= human_food_need:
		veg_rations -= human_food_need
	else:
		# 食物不足，饥饿
		var deficit = human_food_need - veg_rations
		veg_rations = 0
		_hunger_effect("家人", deficit * 0.1)
	
	# 尝试消耗水
	if water >= human_water_need:
		water -= human_water_need
	else:
		var deficit = human_water_need - water
		water = 0
		_hunger_effect("家人", deficit * 0.15)
		survival_event.emit("💧 饮用水不足！")
	
	# 动物每天消耗（通过 AnimalSurvival 处理）
	
	stats_updated.emit()

func _hunger_effect(who: String, severity: float):
	# 饥饿/缺水导致信心下降
	var faith_loss = severity * 5.0
	faith = max(0, faith - faith_loss)
	survival_event.emit(who + " 饥饿！信心下降 " + str(faith_loss))
	
	# 严重时可能导致死亡
	if severity > 0.5 and randf() < severity * 0.1:
		humans_alive = max(1, humans_alive - 1)
		survival_event.emit("💀 一位家人因饥饿去世了...")
