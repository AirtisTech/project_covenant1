extends Node

# 预加载类
const AnimalSpeciesClass = preload("res://scripts/resources/animal_species.gd")

var species_list: Array = []

signal species_status_changed(species, is_placed: bool)

func _ready():
	_init_list()

func set_species_placed(species, status: bool):
	species.is_placed = status
	species_status_changed.emit(species, status)

func _init_list():
	var sheep = AnimalSpeciesClass.new()
	sheep.species_name = "Sheep (Clean)"
	sheep.description = "温顺物种。安顿它们非常容易。"
	sheep.is_clean = true
	sheep.base_width_cubits = 2.0
	sheep.base_weight = 1.0
	sheep.placement_faith_cost = 0.5 
	sheep.visual_color = Color.FLORAL_WHITE
	species_list.append(sheep)
	
	var cow = AnimalSpeciesClass.new()
	cow.species_name = "Cow (Clean)"
	cow.description = "庞大的族群。搬运和安顿需要一定的毅力。"
	cow.is_clean = true
	cow.base_width_cubits = 4.0
	cow.base_weight = 4.0
	cow.placement_faith_cost = 1.5 
	cow.visual_color = Color.TAN
	species_list.append(cow)
	
	var lion = AnimalSpeciesClass.new()
	lion.species_name = "Lion"
	lion.description = "猛兽。安顿狮子需要面对极大的恐惧。"
	lion.is_clean = false
	lion.diet = AnimalSpeciesClass.Diet.CARNIVORE
	lion.base_width_cubits = 6.0
	lion.base_weight = 3.0
	lion.placement_faith_cost = 3.0 
	lion.visual_color = Color.GOLDENROD
	species_list.append(lion)
	
	var elephant = AnimalSpeciesClass.new()
	elephant.species_name = "Elephant"
	elephant.description = "巨型物种。将其吊装进方舟底层是一场信念的磨炼。"
	elephant.is_clean = false
	elephant.base_width_cubits = 15.0
	elephant.base_weight = 15.0
	elephant.placement_faith_cost = 5.0 
	elephant.visual_color = Color.SLATE_GRAY
	species_list.append(elephant)
	
	# 更多清洁动物
	var goat = AnimalSpeciesClass.new()
	goat.species_name = "Goat"
	goat.description = "小巧灵活的山羊。它们喜欢跳来跳去。"
	goat.is_clean = true
	goat.base_width_cubits = 1.5
	goat.base_weight = 0.8
	goat.placement_faith_cost = 0.3
	goat.visual_color = Color.SADDLE_BROWN
	species_list.append(goat)
	
	var camel = AnimalSpeciesClass.new()
	camel.species_name = "Camel"
	camel.description = "沙漠之舟。耐旱能力强，适合长途旅行。"
	camel.is_clean = true
	camel.base_width_cubits = 8.0
	camel.base_weight = 6.0
	camel.placement_faith_cost = 2.0
	camel.visual_color = Color.SANDY_BROWN
	species_list.append(camel)
	
	var horse = AnimalSpeciesClass.new()
	horse.species_name = "Horse"
	horse.description = "忠诚的伙伴。速度快，是很好的交通工具。"
	horse.is_clean = true
	horse.base_width_cubits = 5.0
	horse.base_weight = 4.0
	horse.placement_faith_cost = 1.5
	horse.visual_color = Color.MAROON
	species_list.append(horse)
	
	var rabbit = AnimalSpeciesClass.new()
	rabbit.species_name = "Rabbit"
	rabbit.description = "繁殖迅速的小动物。需要在方舟上妥善安置。"
	rabbit.is_clean = true
	rabbit.base_width_cubits = 1.0
	rabbit.base_weight = 0.3
	rabbit.placement_faith_cost = 0.2
	rabbit.visual_color = Color.LIGHT_GRAY
	species_list.append(rabbit)
	
	var deer = AnimalSpeciesClass.new()
	deer.species_name = "Deer"
	deer.description = "优雅的森林生物。行动敏捷。"
	deer.is_clean = true
	deer.base_width_cubits = 3.0
	deer.base_weight = 2.0
	deer.placement_faith_cost = 0.8
	deer.visual_color = Color.PERU
	species_list.append(deer)
	
	# 不洁动物
	var pig = AnimalSpeciesClass.new()
	pig.species_name = "Pig"
	pig.description = "贪吃的动物。需要特别的空间和清理。"
	pig.is_clean = false
	pig.diet = AnimalSpeciesClass.Diet.OMNIVORE
	pig.base_width_cubits = 3.0
	pig.base_weight = 2.5
	pig.placement_faith_cost = 1.0
	pig.visual_color = Color.PINK
	species_list.append(pig)
	
	var wolf = AnimalSpeciesClass.new()
	wolf.species_name = "Wolf"
	wolf.description = "成群捕猎的猛兽。需要谨慎对待。"
	wolf.is_clean = false
	wolf.diet = AnimalSpeciesClass.Diet.CARNIVORE
	wolf.base_width_cubits = 3.0
	wolf.base_weight = 2.0
	wolf.placement_faith_cost = 2.5
	wolf.visual_color = Color.DIM_GRAY
	species_list.append(wolf)
	
	var bear = AnimalSpeciesClass.new()
	bear.species_name = "Bear"
	bear.description = "强大的猛兽。力量惊人，需要坚固的笼子。"
	bear.is_clean = false
	bear.diet = AnimalSpeciesClass.Diet.CARNIVORE
	bear.base_width_cubits = 7.0
	bear.base_weight = 8.0
	bear.placement_faith_cost = 4.0
	bear.visual_color = Color(0.4, 0.2, 0.1)  # 深棕色
	species_list.append(bear)
	
	var tiger = AnimalSpeciesClass.new()
	tiger.species_name = "Tiger"
	tiger.description = "森林之王。美丽而危险。"
	tiger.is_clean = false
	tiger.diet = AnimalSpeciesClass.Diet.CARNIVORE
	tiger.base_width_cubits = 6.0
	tiger.base_weight = 5.0
	tiger.placement_faith_cost = 3.5
	tiger.visual_color = Color.ORANGE_RED
	species_list.append(tiger)
	
	var monkey = AnimalSpeciesClass.new()
	monkey.species_name = "Monkey"
	monkey.description = "调皮的灵长类。喜欢到处攀爬。"
	monkey.is_clean = false
	monkey.base_width_cubits = 2.0
	monkey.base_weight = 0.5
	monkey.placement_faith_cost = 0.5
	monkey.visual_color = Color.SIENNA
	species_list.append(monkey)