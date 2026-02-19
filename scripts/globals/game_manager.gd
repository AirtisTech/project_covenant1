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
var game_over: bool = false
var victory: bool = false

signal stats_updated()
signal phase_started(new_phase: Phase)
signal resource_changed(resource: String, amount: float)
signal survival_event(message: String)
signal game_ended(victory: bool, message: String)

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
	# 处理农作物生长
	process_daily_crops()
	
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
	
	# 检查胜利条件
	_check_victory()

func _hunger_effect(who: String, severity: float):
	# 饥饿/缺水导致信心下降
	var faith_loss = severity * 5.0
	faith = max(0, faith - faith_loss)
	survival_event.emit(who + " 饥饿！信心下降 " + str(faith_loss))
	
	# 严重时可能导致死亡
	if severity > 0.5 and randf() < severity * 0.1:
		humans_alive = max(1, humans_alive - 1)
		survival_event.emit("💀 一位家人因饥饿去世了...")
	
	# 检查失败条件
	_check_game_over()

func _check_game_over():
	if game_over:
		return
	
	# 失败条件1：所有家人死亡
	if humans_alive <= 0:
		_end_game(false, "所有家人已去世...")
		return
	
	# 失败条件2：信心归零
	if faith <= 0:
		_end_game(false, "信心已耗尽，大家放弃了希望...")
		return

func _check_victory():
	if game_over or victory:
		return
	
	# 胜利条件：漂流阶段完成（150天）
	if current_phase == Phase.DRIFT and day >= 150:
		_end_game(true, "🎉 找到陆地！方舟之旅成功结束！")

func _end_game(is_victory: bool, message: String):
	game_over = true
	victory = is_victory
	game_ended.emit(is_victory, message)
	print("🏆 游戏结束: ", "胜利" if is_victory else "失败", " - ", message)
	survival_event.emit(message if is_victory else "💀 " + message)

# 厨房烹饪系统（不再自动生产食物）
var kitchens_count: int = 0

func add_kitchen():
	kitchens_count += 1
	print("🍳 厨房已建造！")

# 宰杀动物获取食物
func slaughter_animal(species) -> Dictionary:
	# 根据动物种类获取食物
	var food_amount = 0
	var food_type = "meat"
	
	if species.is_clean:
		# 清洁动物可以提供肉食
		food_amount = int(species.base_weight * 10)  # 根据重量计算
		meat_rations += food_amount
		resource_changed.emit("meat", food_amount)
		survival_event.emit("🔪 宰杀了 %s，获得 %d 肉食" % [species.species_name, food_amount])
	else:
		# 不洁动物需要处理
		food_amount = int(species.base_weight * 5)
		meat_rations += food_amount
		resource_changed.emit("meat", food_amount)
		survival_event.emit("🔪 宰杀了 %s，获得 %d 肉食（不洁）" % [species.species_name, food_amount])
	
	return {"type": food_type, "amount": food_amount}

# 农作物系统
var crops: Dictionary = {
	"wheat": {"planted": 0, "ready": 0, "growth_time": 10, "yield": 5},
	"barley": {"planted": 0, "ready": 0, "growth_time": 8, "yield": 4},
	"grapes": {"planted": 0, "ready": 0, "growth_time": 15, "yield": 8}
}

func plant_crop(crop_type: String) -> bool:
	if crops.has(crop_type):
		crops[crop_type]["planted"] += 1
		return true
	return false

func harvest_crop(crop_type: String) -> int:
	if crops.has(crop_type) and crops[crop_type]["ready"] > 0:
		var yield_amount = crops[crop_type]["yield"]
		crops[crop_type]["ready"] -= 1
		veg_rations += yield_amount
		resource_changed.emit("veg", yield_amount)
		survival_event.emit("🌾 收获了 %s +%d 素食" % [crop_type, yield_amount])
		return yield_amount
	return 0

func process_daily_crops():
	# 处理农作物生长
	for crop_type in crops.keys():
		var crop = crops[crop_type]
		if crop["planted"] > 0:
			# 随机生长
			if randf() < 0.3:  # 30% 概率每天生长
				crop["ready"] += 1
				crop["planted"] -= 1
				survival_event.emit("🌱 %s 可以收获了" % crop_type)
