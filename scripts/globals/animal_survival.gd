extends Node

# 预加载
const TaskDataClass = preload("res://scripts/resources/task_data.gd")

# 动物生存系统
# 管理所有动物的饥饿、健康、信仰流失

var animals: Array = []  # 存储所有在方舟上的动物

# 生存参数
const HUNGER_RATE: float = 10.0    # 每天饥饿增长速度
const HEALTH_DECAY: float = 20.0   # 饥饿时的健康衰减
const FAITH_DRAIN: float = 5.0     # 动物死亡时信仰损失

signal animal_hunger_changed(animal, hunger: float)
signal animal_health_changed(animal, health: float)
signal animal_died(animal)
signal daily_survival_report(hungry: int, healthy: int, dead: int)

func _ready():
	print("🦌 AnimalSurvivalSystem initialized")

# 注册动物到生存系统
func register_animal(animal_node):
	if not animals.has(animal_node):
		animals.append(animal_node)
		# 初始化饥饿值为0
		animal_node.set_meta("hunger", 0.0)
		animal_node.set_meta("health", 100.0)
		print("🦌 Animal registered: ", animal_node.name)

# 移除动物
func unregister_animal(animal_node):
	if animals.has(animal_node):
		animals.erase(animal_node)
		print("🦌 Animal removed: ", animal_node.name)

# 动物每天消耗食物
func process_daily():
	var hungry_count = 0
	var healthy_count = 0
	var dead_count = 0
	
	# 先检查是否有食物可以喂动物
	var gm = get_node_or_null("/root/GameManager")
	var has_veg = false
	var has_meat = false
	
	if gm:
		has_veg = gm.veg_rations > 0
		has_meat = gm.meat_rations > 0
	
	for animal in animals:
		if not is_instance_valid(animal):
			continue
		
		var hunger = animal.get_meta("hunger", 0.0)
		var health = animal.get_meta("health", 100.0)
		var species = animal.get_meta("species")
		
		# 检查动物需要什么类型的食物
		var needs_food = "none"
		if species:
			match species.diet:
				0: needs_food = "veg"  # 草食
				1: needs_food = "meat"  # 肉食
				2: needs_food = "any"   # 杂食
		
		# 自动喂食
		var fed = false
		if needs_food == "veg" and has_veg:
			if gm and gm.consume_resource("veg", 1.0):
				hunger = max(0, hunger - 40)
				fed = true
		elif needs_food == "meat" and has_meat:
			if gm and gm.consume_resource("meat", 1.0):
				hunger = max(0, hunger - 40)
				fed = true
		elif needs_food == "any":
			if has_veg and gm and gm.consume_resource("veg", 1.0):
				hunger = max(0, hunger - 35)
				fed = true
			elif has_meat and gm and gm.consume_resource("meat", 1.0):
				hunger = max(0, hunger - 35)
				fed = true
		
		if not fed and hunger >= 50:
			# 没吃饱，增加饥饿值
			hunger += HUNGER_RATE * 0.5
		
		hunger = clamp(hunger, 0, 100)
		animal.set_meta("hunger", hunger)
		animal_hunger_changed.emit(animal, hunger)
		
		# 饥饿时减少健康
		if hunger >= 100:
			health -= HEALTH_DECAY
			animal.set_meta("health", health)
			animal_health_changed.emit(animal, health)
			
			# 动物死亡
			if health <= 0:
				_dead_animal(animal)
				dead_count += 1
				continue
		
		# 统计
		if hunger > 50:
			hungry_count += 1
		else:
			healthy_count += 1
	
	daily_survival_report.emit(hungry_count, healthy_count, dead_count)
	print("📊 Daily Report - Hungry: %d, Healthy: %d, Dead: %d" % [hungry_count, healthy_count, dead_count])

func _create_feeding_tasks():
	var tm = get_node_or_null("/root/TaskManager")
	if not tm:
		return
	
	# 为每只饥饿的动物创建喂食任务
	for animal in animals:
		if not is_instance_valid(animal):
			continue
		
		var hunger = animal.get_meta("hunger", 0.0)
		if hunger > 50:
			var species = animal.get_meta("species")
			if species:
				# 根据动物食性创建任务
				var food_type = "veg"
				if species.diet == 1:  # CARNIVORE
					food_type = "meat"
				
				# 使用动物的世界位置作为任务位置
				var task_pos = animal.global_position
				tm.call("add_task", TaskDataClass.Type.FEED, task_pos, 2, animal)
				print("📝 Created FEED task for ", species.species_name)

func _dead_animal(animal):
	# 信仰损失
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.call("modify_faith", -FAITH_DRAIN)
	
	animal_died.emit(animal)
	print("💀 Animal died! Faith -%d" % FAITH_DRAIN)

# 喂食动物
func feed_animal(animal, food_type: String) -> bool:
	if not animals.has(animal):
		return false
	
	var species = animal.get_meta("species")
	if not species:
		return false
	
	# 检查食物类型是否正确
	var correct_food = false
	match species.diet:
		0:  # HERBIVORE
			correct_food = (food_type == "veg")
		1:  # CARNIVORE
			correct_food = (food_type == "meat")
		2:  # OMNIVORE
			correct_food = true
	
	if correct_food:
		var hunger = animal.get_meta("hunger", 0.0)
		hunger = max(0, hunger - 30)
		animal.set_meta("hunger", hunger)
		animal_hunger_changed.emit(animal, hunger)
		return true
	
	return false

# 获取饥饿的动物列表
func get_hungry_animals() -> Array:
	var hungry = []
	for animal in animals:
		if is_instance_valid(animal):
			var hunger = animal.get_meta("hunger", 0.0)
			if hunger > 50:
				hungry.append(animal)
	return hungry
