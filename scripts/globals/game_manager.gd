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
	
	# 家人登船
	var fm = get_node_or_null("/root/FamilyManager")
	if fm:
		fm.spawn_family()
	
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
	
	# 更新动物数量统计
	var survival = get_node_or_null("/root/AnimalSurvival")
	if survival:
		animals_alive = survival.get_alive_count()
	
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
	
	# 漂流阶段处理
	if current_phase == Phase.DRIFT:
		_process_drift()
	
	# 检查胜利条件
	_check_victory()

func _check_victory():
	if game_over or victory:
		return
	
	# 胜利条件1：漂流到陆地
	if current_phase == Phase.DRIFT and distance_to_land <= 0:
		_end_game(true, "🎉 找到陆地！方舟之旅成功结束！")
		return
	
	# 胜利条件2：漂流阶段完成（150天）
	if current_phase == Phase.DRIFT and day >= 150:
		_end_game(true, "🎉 150天漂流结束，成功生存！")

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

# 漂流阶段
var drift_direction: float = 0.0  # 漂流方向
var distance_to_land: int = 1000  # 距离陆地公里数
var drift_events: Array = []  # 漂流事件
var is_land_sighted: bool = false  # 是否发现陆地

func start_drift_phase():
	current_phase = Phase.DRIFT
	drift_direction = randf_range(-1, 1)
	distance_to_land = 1000 + randi() % 500
	is_land_sighted = false
	print("🛶 进入漂流阶段！距离陆地约 ", distance_to_land, " 公里")
	survival_event.emit("🛶 漂流开始！寻找陆地...")

func _process_drift():
	# 漂流阶段特有事件
	if current_phase != Phase.DRIFT:
		return
	
	# 每天漂流距离
	var daily_drift = randf_range(5, 15)
	distance_to_land = max(0, distance_to_land - daily_drift)
	
	# 随机事件
	if randf() < 0.2:  # 20% 概率触发事件
		_trigger_drift_event()
	
	# 发现陆地
	if distance_to_land <= 50 and not is_land_sighted:
		is_land_sighted = true
		survival_event.emit("🗺️ 发现陆地！方向：%s" % _get_direction_text())

func _get_direction_text() -> String:
	if drift_direction < -0.3:
		return "西"
	elif drift_direction > 0.3:
		return "东"
	else:
		return "前方"

func _trigger_drift_event():
	var events = [
		{"msg": "🐟 捕获大量鱼群，食物+50", "type": "food"},
		{"msg": "🌧️ 收集雨水，水+30", "type": "water"},
		{"msg": "🕊️ 鸽子带来好消息，信心+10", "type": "faith"},
		{"msg": "🪵 发现漂浮的木材", "type": "wood"},
		{"msg": "🦈 鲨鱼袭击，损失一些食物", "type": "danger"},
		{"msg": "🌊 大浪来袭，摇晃剧烈", "type": "storm"},
		{"msg": "😴 大家在漂流中疲惫不堪", "type": "rest"},
		{"msg": "🌈 彩虹出现！大家重拾希望，信心+15", "type": "faith"},
		{"msg": "🐋 遇到温和的鲸鱼，大家很兴奋", "type": "faith"},
		{"msg": "🌙 流星划过夜空", "type": "faith"},
		{"msg": "🦅 老鹰指引方向，信心+5", "type": "faith"},
		{"msg": "💨 顺风！漂流速度加快", "type": "speed"},
		{"msg": "🌊 逆风，漂流受阻", "type": "slow"},
		{"msg": "☀️ 晴朗的一天，大家心情愉快", "type": "faith"},
		{"msg": "📦 发现一个漂浮的箱子，物资+20", "type": "food"},
		{"msg": "🧜 传说中海妖的歌声让大家不安", "type": "danger"},
		{"msg": "🦑 大乌贼出现，损坏部分设施", "type": "danger"},
		{"msg": "🍀 奇迹般地找到一些野果，食物+15", "type": "food"},
		{"msg": "🌫️ 大雾弥漫，迷失方向", "type": "slow"}
	]
	
	var event = events[randi() % events.size()]
	drift_events.append(event)
	survival_event.emit(event["msg"])
	
	match event["type"]:
		"food":
			veg_rations += randi_range(15, 50)
		"water":
			water += randi_range(20, 40)
		"faith":
			faith = min(100, faith + randi_range(5, 15))
		"danger":
			veg_rations = max(0, veg_rations - randi_range(10, 30))
			water = max(0, water - randi_range(5, 15))
		"speed":
			# 漂流更快
			distance_to_land = max(0, distance_to_land - randi_range(20, 40))
		"slow":
			# 漂流变慢
			distance_to_land += randi_range(10, 20)
		"wood":
			# 木材可以用于修复或建造
			pass

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
