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

# 瘟疫系统
var plague_active: bool = false
var plague_spread_timer: float = 0.0
const PLAGUE_SPREAD_INTERVAL: float = 3.0  # 瘟疫传播间隔
const PLAGUE_DAMAGE: float = 15.0  # 瘟疫伤害

signal animal_hunger_changed(animal, hunger: float)
signal animal_health_changed(animal, health: float)
signal animal_died(animal)
signal animal_born(species, count: int)
signal plague_started()
signal plague_ended()
signal daily_survival_report(hungry: int, healthy: int, dead: int)

func _ready():
	print("🦌 AnimalSurvivalSystem initialized")

func _process(delta):
	# 处理瘟疫传播
	if plague_active:
		_process_plague(delta)
		
		# 瘟疫有一定概率结束（如果没有健康动物了）
		var healthy_count = 0
		for animal in animals:
			if is_instance_valid(animal) and not animal.get_meta("has_plague", false):
				healthy_count += 1
		
		if healthy_count == 0:
			# 所有动物都感染了，一段时间后瘟疫结束
			if randf() < 0.01:  # 1% 概率每天结束
				_end_plague()

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
	# 检查是否超过容量
	var current_count = 0
	for a in animals:
		if is_instance_valid(a):
			var s = a.get_meta("species")
			if s and s.species_name == species.species_name:
				current_count += 1
	
	var max_capacity = species.total_animals * 1.5  # 允许超过50%
	
	if current_count >= max_capacity and not plague_active:
		# 触发瘟疫
		_start_plague(species)
		return
	
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
	new_animal.set_meta("has_plague", false)  # 新动物初始没有瘟疫
	register_animal(new_animal)
	
	animal_born.emit(species, 1)
	print("🐣 %s 繁殖了新一代！" % species.species_name)
	
	# 检查是否触发瘟疫
	_check_plague_trigger(species)

func _check_plague_trigger(species):
	var current_count = 0
	for a in animals:
		if is_instance_valid(a):
			var s = a.get_meta("species")
			if s and s.species_name == species.species_name:
				current_count += 1
	
	var max_capacity = species.total_animals
	
	if current_count > max_capacity and not plague_active:
		_start_plague(species)

func _start_plague(patient_zero_species):
	plague_active = true
	plague_spread_timer = 0.0
	plague_started.emit()
	print("💀 瘟疫爆发！%s 携带病原体" % patient_zero_species.species_name)
	
	# 随机让几只动物感染
	var infected_count = 0
	for animal in animals:
		if is_instance_valid(animal):
			var s = animal.get_meta("species")
			if s and s.species_name == patient_zero_species.species_name:
				animal.set_meta("has_plague", true)
				infected_count += 1
				if infected_count >= 3:
					break
	
	# 发送警告
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.survival_event.emit("💀 警告：瘟疫在动物间传播！")

func _process_plague(delta):
	if not plague_active:
		return
	
	plague_spread_timer += delta
	if plague_spread_timer >= PLAGUE_SPREAD_INTERVAL:
		plague_spread_timer = 0.0
		_spread_plague()

func _spread_plague():
	# 瘟疫传播给附近的动物
	for animal in animals:
		if not is_instance_valid(animal):
			continue
		
		# 如果已经有瘟疫，传播给附近的健康动物
		if animal.get_meta("has_plague", false):
			var pos = animal.global_position
			for other in animals:
				if not is_instance_valid(other):
					continue
				if other.get_meta("has_plague", false):
					continue
				
				var other_pos = other.global_position
				if pos.distance_to(other_pos) < 50:  # 50像素内的动物
					# 50% 概率感染
					if randf() < 0.5:
						other.set_meta("has_plague", true)
						print("💀 瘟疫传染给了附近的动物")
		
		# 有瘟疫的动物持续掉血
		var health = animal.get_meta("health", 100.0)
		health -= PLAGUE_DAMAGE
		animal.set_meta("health", health)
		animal_health_changed.emit(animal, health)
		
		# 严重时死亡
		if health <= 0:
			_dead_animal(animal)

func _end_plague():
	plague_active = false
	plague_ended.emit()
	print("✅ 瘟疫结束了")
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.survival_event.emit("✅ 瘟疫已结束")

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
		gm.add_faith(-FAITH_DRAIN)
	
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
