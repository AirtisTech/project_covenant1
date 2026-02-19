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
signal animal_born(species, count: int)  # 新增：动物出生信号
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

# 每天生存处理 - 动物不会自动吃，需要人类喂养
func process_daily():
	var hungry_count = 0
	var healthy_count = 0
	var dead_count = 0
	
	for animal in animals:
		if not is_instance_valid(animal):
			continue
		
		var hunger = animal.get_meta("hunger", 0.0)
		var health = animal.get_meta("health", 100.0)
		
		# 增加饥饿值（每天增加）
		hunger += HUNGER_RATE
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
			# 创建喂食任务
			_create_feeding_task(animal)
		else:
			healthy_count += 1
	
	daily_survival_report.emit(hungry_count, healthy_count, dead_count)
	print("📊 Daily Report - Hungry: %d, Healthy: %d, Dead: %d" % [hungry_count, healthy_count, dead_count])
	
	# 繁殖系统：喂饱的动物有机会繁殖
	_process_breeding()

func _process_breeding():
	# 只有健康且吃饱的动物才能繁殖
	var breeding_chance = 0.1  # 10% 概率
	
	for animal in animals:
		if not is_instance_valid(animal):
			continue
		
		var hunger = animal.get_meta("hunger", 0.0)
		var health = animal.get_meta("health", 100.0)
		
		# 只有吃饱(饥饿值<30)且健康(>70)的动物才能繁殖
		if hunger < 30 and health > 70:
			if randf() < breeding_chance:
				var species = animal.get_meta("species")
				if species:
					_breed_animal(species)

func _breed_animal(species):
	# 繁殖成功，添加新动物
	var ark = get_tree().root.find_child("ArkSystem", true, false)
	if not ark:
		return
	
	# 创建新动物
	var new_animal = ColorRect.new()
	new_animal.size = Vector2(16, 12)
	new_animal.color = species.visual_color
	new_animal.position = species.get("last_placed_pos", Vector2(200, 340)) + Vector2(randf_range(-30, 30), 0)
	new_animal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ark.add_child(new_animal)
	
	# 注册到生存系统
	new_animal.set_meta("species", species)
	new_animal.set_meta("hunger", 0.0)
	new_animal.set_meta("health", 100.0)
	register_animal(new_animal)
	
	animal_born.emit(species, 1)
	print("🐣 %s 繁殖了新一代！" % species.species_name)

func _create_feeding_task(animal):
	var tm = get_node_or_null("/root/TaskManager")
	if not tm:
		return
	
	var species = animal.get_meta("species")
	if not species:
		return
	
	# 根据食性创建喂食任务
	var food_type = "veg"
	if species.diet == 1:  # CARNIVORE
		food_type = "meat"
	elif species.diet == 2:  # OMNIVORE
		food_type = "any"
	
	var task_pos = animal.global_position
	tm.call("add_task", TaskDataClass.Type.FEED, task_pos, food_type, animal)
	print("📝 创建喂食任务: ", species.species_name, " (需要", food_type, ")")

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
