extends Node

# 灾难事件系统
# 在大洪水阶段触发各种灾难事件

enum DisasterType {
	NONE,
	STORM,        # 暴风雨
	HULL_DAMAGE, # 船体破损
	ANIMAL_ESCAPE, # 动物逃跑
	FIRE,        # 火灾
	FOOD_ROT     # 食物腐烂
}

var current_disaster: DisasterType = DisasterType.NONE
var disaster_timer: float = 0.0
var time_until_next_disaster: float = 60.0  # 秒

# 灾难参数
const STORM_FREQUENCY: float = 30.0   # 暴风雨间隔
const HULL_DAMAGE_CHANCE: float = 0.1  # 每次暴风雨船体破损概率

signal disaster_started(type: DisasterType)
signal disaster_ended(type: DisasterType)
signal hull_damaged(amount: float)
signal faith_crisis(level: float)

func _ready():
	print("⚠️ DisasterSystem initialized")

func _process(delta):
	# 只在大洪水阶段发生灾难
	var pm = get_node_or_null("/root/PhaseManager")
	if not pm or pm.current_phase != pm.Phase.DELUGE:
		return
	
	# 如果当前有灾难，不触发新的
	if current_disaster != DisasterType.NONE:
		_process_current_disaster(delta)
		return
	
	# 计时器
	disaster_timer += delta
	if disaster_timer >= time_until_next_disaster:
		_trigger_random_disaster()
		disaster_timer = 0.0
		# 重置下次灾难时间（随机）
		time_until_next_disaster = randf_range(30.0, 90.0)

func _trigger_random_disaster():
	var roll = randf()
	
	if roll < 0.5:
		_start_disaster(DisasterType.STORM)
	elif roll < 0.7:
		_start_disaster(DisasterType.HULL_DAMAGE)
	elif roll < 0.85:
		_start_disaster(DisasterType.ANIMAL_ESCAPE)
	else:
		# 小灾难不给太多提示
		print("⚠️ Weather unstable...")
		var pm = get_node_or_null("/root/PhaseManager")
		if pm:
			pm.is_storming = true

func _start_disaster(type: DisasterType):
	current_disaster = type
	disaster_started.emit(type)
	
	match type:
		DisasterType.STORM:
			print("🌧️ 暴风雨来了！")
			var pm = get_node_or_null("/root/PhaseManager")
			if pm:
				pm.is_storming = true
				pm.weather_intensity = 0.7
				# 船体损伤
				if randf() < HULL_DAMAGE_CHANCE:
					_take_hull_damage(randf_range(10, 30))
		
		DisasterType.HULL_DAMAGE:
			print("💥 船体受损！")
			_take_hull_damage(randf_range(20, 50))
		
		DisasterType.ANIMAL_ESCAPE:
			print("🦌 动物逃跑！")
			_animal_escape()
	
	# 灾难持续时间
	await get_tree().create_timer(randf_range(10.0, 30.0)).timeout
	_end_disaster(type)

func _process_current_disaster(delta):
	# 灾难进行中的特殊处理
	pass

func _end_disaster(type: DisasterType):
	current_disaster = DisasterType.NONE
	disaster_ended.emit(type)
	
	# 恢复天气
	var pm = get_node_or_null("/root/PhaseManager")
	if pm:
		if type == DisasterType.STORM:
			pm.is_storming = false
			pm.weather_intensity = 0.0
	
	print("✅ 灾难结束")

func _take_hull_damage(amount: float):
	hull_damaged.emit(amount)
	# 信仰危机
	var faith_impact = amount * 0.5
	faith_crisis.emit(faith_impact)
	
	# 扣除信仰
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.add_faith(-faith_impact)
	
	print("💔 船体受损 %d, 信仰下降 %.1f" % [amount, faith_impact])

func _animal_escape():
	# 随机让一个动物逃跑（移除）
	var survival = get_node_or_null("/root/AnimalSurvival")
	if survival and survival.animals.size() > 0:
		var random_animal = survival.animals.pick_random()
		if random_animal and is_instance_valid(random_animal):
			survival.unregister_animal(random_animal)
			random_animal.queue_free()
			print("🦌 一只动物逃跑了！")

func get_disaster_name() -> String:
	match current_disaster:
		DisasterType.STORM: return "🌧️ 暴风雨"
		DisasterType.HULL_DAMAGE: return "💥 船体破损"
		DisasterType.ANIMAL_ESCAPE: return "🦌 动物逃跑"
		_: return ""
