extends Node

# 预加载类
const AnimalSpeciesClass = preload("res://scripts/resources/animal_species.gd")
const FacilityClass = preload("res://scripts/resources/facility.gd")

var species_list: Array = []
var facility_list: Array = []

signal species_status_changed(species, is_placed: bool)
signal facility_status_changed(facility, is_placed: bool)

func _ready():
	_init_list()
	_init_facilities()

func set_species_placed(species, status: bool):
	species.is_placed = status
	species_status_changed.emit(species, status)

func set_facility_placed(facility, status: bool):
	facility.is_placed = status
	facility_status_changed.emit(facility, status)

func _init_facilities():
	# 动物栏
	var animal_pen = FacilityClass.new()
	animal_pen.facility_name = "动物栏"
	animal_pen.description = "用于安置动物的围栏"
	animal_pen.type = FacilityClass.FacilityType.ANIMAL_PEN
	animal_pen.width_cells = 3
	animal_pen.height_cells = 1
	animal_pen.faith_cost = 1.0
	animal_pen.capacity = 4
	animal_pen.visual_color = Color(0.5, 0.35, 0.2)
	facility_list.append(animal_pen)
	
	# 厨房
	var kitchen = FacilityClass.new()
	kitchen.facility_name = "厨房"
	kitchen.description = "烹饪食物的地方"
	kitchen.type = FacilityClass.FacilityType.KITCHEN
	kitchen.width_cells = 2
	kitchen.height_cells = 1
	kitchen.faith_cost = 1.5
	kitchen.resource_production = 1.0
	kitchen.visual_color = Color(0.8, 0.6, 0.4)
	facility_list.append(kitchen)
	
	# 卧室
	var bedroom = FacilityClass.new()
	bedroom.facility_name = "卧室"
	bedroom.description = "家人休息的地方"
	bedroom.type = FacilityClass.FacilityType.BEDROOM
	bedroom.width_cells = 3
	bedroom.height_cells = 1
	bedroom.faith_cost = 2.0
	bedroom.capacity = 2
	bedroom.visual_color = Color(0.6, 0.5, 0.7)
	facility_list.append(bedroom)
	
	# 食物储藏室
	var food_storage = FacilityClass.new()
	food_storage.facility_name = "食物储藏室"
	food_storage.description = "存放食物的空间"
	food_storage.type = FacilityClass.FacilityType.FOOD_STORAGE
	food_storage.width_cells = 4
	food_storage.height_cells = 1
	food_storage.faith_cost = 1.5
	food_storage.capacity = 20
	food_storage.visual_color = Color(0.7, 0.5, 0.3)
	facility_list.append(food_storage)
	
	# 水箱
	var water_tank = FacilityClass.new()
	water_tank.facility_name = "水箱"
	water_tank.description = "储存饮用水的容器"
	water_tank.type = FacilityClass.FacilityType.WATER_TANK
	water_tank.width_cells = 2
	water_tank.height_cells = 1
	water_tank.faith_cost = 1.0
	water_tank.capacity = 15
	water_tank.visual_color = Color(0.3, 0.6, 0.9)
	facility_list.append(water_tank)
	
	# 医务室
	var medical_bay = FacilityClass.new()
	medical_bay.facility_name = "医务室"
	medical_bay.description = "治疗伤病的地方"
	medical_bay.type = FacilityClass.FacilityType.MEDICAL_BAY
	medical_bay.width_cells = 2
	medical_bay.height_cells = 1
	medical_bay.faith_cost = 2.5
	medical_bay.visual_color = Color(0.9, 0.9, 0.9)
	facility_list.append(medical_bay)
	
	# 工作间
	var workshop = FacilityClass.new()
	workshop.facility_name = "工作间"
	workshop.description = "制作和修理物品的地方"
	workshop.type = FacilityClass.FacilityType.WORKSHOP
	workshop.width_cells = 3
	workshop.height_cells = 1
	workshop.faith_cost = 2.0
	workshop.visual_color = Color(0.5, 0.4, 0.3)
	facility_list.append(workshop)

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
	
	# ===== 更多清洁动物 =====
	var dove = AnimalSpeciesClass.new()
	dove.species_name = "Dove"
	dove.description = "和平的象征。善于飞翔。"
	dove.is_clean = true
	dove.base_width_cubits = 1.0
	dove.base_weight = 0.2
	dove.placement_faith_cost = 0.1
	dove.visual_color = Color.WHITE
	species_list.append(dove)
	
	var chicken = AnimalSpeciesClass.new()
	chicken.species_name = "Chicken"
	chicken.description = "家禽。提供蛋和肉。"
	chicken.is_clean = true
	chicken.base_width_cubits = 1.0
	chicken.base_weight = 0.3
	chicken.placement_faith_cost = 0.2
	chicken.visual_color = Color(1, 0.9, 0.6)
	species_list.append(chicken)
	
	var duck = AnimalSpeciesClass.new()
	duck.species_name = "Duck"
	duck.description = "水禽。善于游泳。"
	duck.is_clean = true
	duck.base_width_cubits = 1.5
	duck.base_weight = 0.4
	duck.placement_faith_cost = 0.2
	duck.visual_color = Color(0.6, 0.8, 0.4)
	species_list.append(duck)
	
	var goose = AnimalSpeciesClass.new()
	goose.species_name = "Goose"
	goose.description = "警觉性高的水禽。"
	goose.is_clean = true
	goose.base_width_cubits = 2.0
	goose.base_weight = 0.5
	goose.placement_faith_cost = 0.3
	goose.visual_color = Color(0.9, 0.9, 0.95)
	species_list.append(goose)
	
	var donkey = AnimalSpeciesClass.new()
	donkey.species_name = "Donkey"
	donkey.description = "耐力的搬运助手。"
	donkey.is_clean = true
	donkey.base_width_cubits = 4.0
	donkey.base_weight = 3.0
	donkey.placement_faith_cost = 1.0
	donkey.visual_color = Color(0.5, 0.5, 0.5)
	species_list.append(donkey)
	
	var ox = AnimalSpeciesClass.new()
	ox.species_name = "Ox"
	ox.description = "耕田好帮手。力量强大。"
	ox.is_clean = true
	ox.base_width_cubits = 5.0
	ox.base_weight = 5.0
	ox.placement_faith_cost = 1.5
	ox.visual_color = Color(0.4, 0.3, 0.2)
	species_list.append(ox)
	
	var pigeon = AnimalSpeciesClass.new()
	pigeon.species_name = "Pigeon"
	pigeon.description = "天空的使者。"
	pigeon.is_clean = true
	pigeon.base_width_cubits = 1.0
	pigeon.base_weight = 0.2
	pigeon.placement_faith_cost = 0.1
	pigeon.visual_color = Color(0.7, 0.7, 0.75)
	species_list.append(pigeon)
	
	# ===== 更多不洁动物 =====
	var hyena = AnimalSpeciesClass.new()
	hyena.species_name = "Hyena"
	hyena.description = "机会主义猎食者。"
	hyena.is_clean = false
	hyena.diet = AnimalSpeciesClass.Diet.CARNIVORE
	hyena.base_width_cubits = 3.0
	hyena.base_weight = 2.0
	hyena.placement_faith_cost = 2.0
	hyena.visual_color = Color(0.6, 0.55, 0.4)
	species_list.append(hyena)
	
	var vulture = AnimalSpeciesClass.new()
	vulture.species_name = "Vulture"
	vulture.description = "食腐动物。"
	vulture.is_clean = false
	vulture.diet = AnimalSpeciesClass.Diet.CARNIVORE
	vulture.base_width_cubits = 2.0
	vulture.base_weight = 0.8
	vulture.placement_faith_cost = 1.0
	vulture.visual_color = Color(0.3, 0.25, 0.2)
	species_list.append(vulture)
	
	var crocodile = AnimalSpeciesClass.new()
	crocodile.species_name = "Crocodile"
	crocodile.description = "危险的爬行动物。"
	crocodile.is_clean = false
	crocodile.diet = AnimalSpeciesClass.Diet.CARNIVORE
	crocodile.base_width_cubits = 12.0
	crocodile.base_weight = 10.0
	crocodile.placement_faith_cost = 4.0
	crocodile.visual_color = Color(0.2, 0.4, 0.2)
	species_list.append(crocodile)
	
	var snake = AnimalSpeciesClass.new()
	snake.species_name = "Snake"
	snake.description = "滑行的猎食者。"
	snake.is_clean = false
	snake.diet = AnimalSpeciesClass.Diet.CARNIVORE
	snake.base_width_cubits = 3.0
	snake.base_weight = 0.5
	snake.placement_faith_cost = 1.5
	snake.visual_color = Color(0.3, 0.5, 0.3)
	species_list.append(snake)
	
	var scorpion = AnimalSpeciesClass.new()
	scorpion.species_name = "Scorpion"
	scorpion.description = "沙漠中的危险生物。"
	scorpion.is_clean = false
	scorpion.diet = AnimalSpeciesClass.Diet.CARNIVORE
	scorpion.base_width_cubits = 1.0
	scorpion.base_weight = 0.1
	scorpion.placement_faith_cost = 0.8
	scorpion.visual_color = Color(0.2, 0.1, 0.1)
	species_list.append(scorpion)
	
	var spider = AnimalSpeciesClass.new()
	spider.species_name = "Spider"
	spider.description = "织网高手。"
	spider.is_clean = false
	spider.diet = AnimalSpeciesClass.Diet.CARNIVORE
	spider.base_width_cubits = 1.0
	spider.base_weight = 0.05
	spider.placement_faith_cost = 0.5
	spider.visual_color = Color(0.1, 0.1, 0.1)
	species_list.append(spider)
	
	var rat = AnimalSpeciesClass.new()
	rat.species_name = "Rat"
	rat.description = "繁殖迅速的小型哺乳动物。"
	rat.is_clean = false
	rat.diet = AnimalSpeciesClass.Diet.OMNIVORE
	rat.base_width_cubits = 1.0
	rat.base_weight = 0.1
	rat.placement_faith_cost = 0.3
	rat.visual_color = Color(0.5, 0.45, 0.4)
	species_list.append(rat)
	
	# ===== 更多独特动物 =====
	var giraffe = AnimalSpeciesClass.new()
	giraffe.species_name = "Giraffe"
	giraffe.description = "高耸的长颈鹿。需要高耸的空间。"
	giraffe.is_clean = true
	giraffe.base_width_cubits = 3.0
	giraffe.base_weight = 5.0
	giraffe.placement_faith_cost = 2.0
	giraffe.visual_color = Color(0.85, 0.65, 0.3)
	species_list.append(giraffe)
	
	var zebra = AnimalSpeciesClass.new()
	zebra.species_name = "Zebra"
	zebra.description = "斑纹美丽的非洲马。"
	zebra.is_clean = true
	zebra.base_width_cubits = 3.5
	zebra.base_weight = 3.5
	zebra.placement_faith_cost = 1.2
	zebra.visual_color = Color(0.95, 0.95, 0.95)
	species_list.append(zebra)
	
	var hippo = AnimalSpeciesClass.new()
	hippo.species_name = "Hippo"
	hippo.description = "河马。需要大量水源。"
	hippo.is_clean = false
	hippo.diet = AnimalSpeciesClass.Diet.HERBIVORE
	hippo.base_width_cubits = 10.0
	hippo.base_weight = 12.0
	hippo.placement_faith_cost = 4.5
	hippo.visual_color = Color(0.5, 0.4, 0.55)
	species_list.append(hippo)
	
	var rhino = AnimalSpeciesClass.new()
	rhino.species_name = "Rhino"
	rhino.description = "犀牛。体型巨大，力大无穷。"
	rhino.is_clean = false
	rhino.base_width_cubits = 9.0
	rhino.base_weight = 10.0
	rhino.placement_faith_cost = 4.0
	rhino.visual_color = Color(0.45, 0.45, 0.48)
	species_list.append(rhino)
	
	var peacock = AnimalSpeciesClass.new()
	peacock.species_name = "Peacock"
	peacock.description = "华丽的大型鸟类。"
	peacock.is_clean = true
	peacock.base_width_cubits = 3.0
	peacock.base_weight = 0.5
	peacock.placement_faith_cost = 0.6
	peacock.visual_color = Color(0.2, 0.4, 0.6)
	species_list.append(peacock)
	
	var parrot = AnimalSpeciesClass.new()
	parrot.species_name = "Parrot"
	parrot.description = "色彩鲜艳的鸟类，能学人说话。"
	parrot.is_clean = true
	parrot.base_width_cubits = 1.5
	parrot.base_weight = 0.3
	parrot.placement_faith_cost = 0.4
	parrot.visual_color = Color(0.9, 0.2, 0.2)
	species_list.append(parrot)
	
	var owl = AnimalSpeciesClass.new()
	owl.species_name = "Owl"
	owl.description = "夜间活动的猛禽。"
	owl.is_clean = true
	owl.base_width_cubits = 2.0
	owl.base_weight = 0.4
	owl.placement_faith_cost = 0.5
	owl.visual_color = Color(0.6, 0.55, 0.5)
	species_list.append(owl)
	
	var bat = AnimalSpeciesClass.new()
	bat.species_name = "Bat"
	bat.description = "夜间飞行的小型哺乳动物。"
	bat.is_clean = false
	bat.base_width_cubits = 1.5
	bat.base_weight = 0.1
	bat.placement_faith_cost = 0.3
	bat.visual_color = Color(0.2, 0.15, 0.15)
	species_list.append(bat)
	
	var fox = AnimalSpeciesClass.new()
	fox.species_name = "Fox"
	fox.description = "狡猾的猎食者。"
	fox.is_clean = false
	fox.diet = AnimalSpeciesClass.Diet.CARNIVORE
	fox.base_width_cubits = 2.5
	fox.base_weight = 1.5
	fox.placement_faith_cost = 1.5
	fox.visual_color = Color(0.9, 0.5, 0.2)
	species_list.append(fox)
	
	var leech = AnimalSpeciesClass.new()
	leech.species_name = "Leech"
	leech.description = "吸血的环节动物。"
	leech.is_clean = false
	leech.diet = AnimalSpeciesClass.Diet.CARNIVORE
	leech.base_width_cubits = 0.5
	leech.base_weight = 0.02
	leech.placement_faith_cost = 0.2
	leech.visual_color = Color(0.3, 0.2, 0.25)
	species_list.append(leech)
	
	# ===== 更多独特动物 =====
	var crane = AnimalSpeciesClass.new()
	crane.species_name = "Crane"
	crane.description = "优雅的长腿鸟类。"
	crane.is_clean = true
	crane.base_width_cubits = 2.5
	crane.base_weight = 0.4
	crane.placement_faith_cost = 0.5
	crane.visual_color = Color(0.95, 0.9, 0.85)
	species_list.append(crane)
	
	var pelican = AnimalSpeciesClass.new()
	pelican.species_name = "Pelican"
	pelican.description = "大型捕鱼鸟类。"
	pelican.is_clean = true
	pelican.base_width_cubits = 4.0
	pelican.base_weight = 1.0
	pelican.placement_faith_cost = 0.8
	pelican.visual_color = Color(0.95, 0.95, 0.9)
	species_list.append(pelican)
	
	var stork = AnimalSpeciesClass.new()
	stork.species_name = "Stork"
	stork.description = "传说中的送子鸟。"
	stork.is_clean = true
	stork.base_width_cubits = 3.5
	stork.base_weight = 0.7
	stork.placement_faith_cost = 0.7
	stork.visual_color = Color(1.0, 1.0, 1.0)
	species_list.append(stork)
	
	var ibis = AnimalSpeciesClass.new()
	ibis.species_name = "Ibis"
	ibis.description = "优雅的白色水鸟。"
	ibis.is_clean = true
	ibis.base_width_cubits = 2.0
	ibis.base_weight = 0.4
	ibis.placement_faith_cost = 0.4
	ibis.visual_color = Color(0.9, 0.95, 1.0)
	species_list.append(ibis)
	
	var swan = AnimalSpeciesClass.new()
	swan.species_name = "Swan"
	swan.description = "美丽的天鹅。"
	swan.is_clean = true
	swan.base_width_cubits = 4.0
	swan.base_weight = 1.2
	swan.placement_faith_cost = 0.9
	swan.visual_color = Color(1.0, 1.0, 1.0)
	species_list.append(swan)
	
	var flamingo = AnimalSpeciesClass.new()
	flamingo.species_name = "Flamingo"
	flamingo.description = "独特的粉红色鸟类。"
	flamingo.is_clean = true
	flamingo.base_width_cubits = 3.0
	flamingo.base_weight = 0.6
	flamingo.placement_faith_cost = 0.6
	flamingo.visual_color = Color(1.0, 0.7, 0.7)
	species_list.append(flamingo)
	
	var heron = AnimalSpeciesClass.new()
	heron.species_name = "Heron"
	heron.description = "水边的钓鱼高手。"
	heron.is_clean = true
	heron.base_width_cubits = 3.5
	heron.base_weight = 0.5
	heron.placement_faith_cost = 0.5
	heron.visual_color = Color(0.5, 0.55, 0.6)
	species_list.append(heron)
	
	# ===== 更多独特动物 =====
	var yak = AnimalSpeciesClass.new()
	yak.species_name = "Yak"
	yak.description = "高原的负重能手。"
	yak.is_clean = true
	yak.base_width_cubits = 6.0
	yak.base_weight = 5.0
	yak.placement_faith_cost = 1.8
	yak.visual_color = Color(0.3, 0.25, 0.2)
	species_list.append(yak)
	
	var buffalo = AnimalSpeciesClass.new()
	buffalo.species_name = "Water Buffalo"
	buffalo.description = "善于游泳的水牛。"
	buffalo.is_clean = true
	buffalo.base_width_cubits = 7.0
	buffalo.base_weight = 6.0
	buffalo.placement_faith_cost = 2.0
	buffalo.visual_color = Color(0.35, 0.35, 0.4)
	species_list.append(buffalo)
	
	var moose = AnimalSpeciesClass.new()
	moose.species_name = "Moose"
	moose.description = "巨大的北方鹿科动物。"
	moose.is_clean = true
	moose.base_width_cubits = 8.0
	moose.base_weight = 7.0
	moose.placement_faith_cost = 2.5
	moose.visual_color = Color(0.4, 0.3, 0.25)
	species_list.append(moose)
	
	var bison = AnimalSpeciesClass.new()
	bison.species_name = "Bison"
	bison.description = "北美大平原的野牛。"
	bison.is_clean = true
	bison.base_width_cubits = 8.0
	bison.base_weight = 8.0
	bison.placement_faith_cost = 2.5
	bison.visual_color = Color(0.45, 0.4, 0.35)
	species_list.append(bison)
	
	var walrus = AnimalSpeciesClass.new()
	walrus.species_name = "Walrus"
	walrus.description = "北极的大型海洋哺乳动物。"
	walrus.is_clean = false
	walrus.diet = AnimalSpeciesClass.Diet.OMNIVORE
	walrus.base_width_cubits = 10.0
	walrus.base_weight = 12.0
	walrus.placement_faith_cost = 4.0
	walrus.visual_color = Color(0.55, 0.45, 0.4)
	species_list.append(walrus)
	
	var seal = AnimalSpeciesClass.new()
	seal.species_name = "Seal"
	seal.description = "可爱的大型海豹。"
	seal.is_clean = false
	seal.diet = AnimalSpeciesClass.Diet.CARNIVORE
	seal.base_width_cubits = 5.0
	seal.base_weight = 4.0
	seal.placement_faith_cost = 2.0
	seal.visual_color = Color(0.5, 0.5, 0.55)
	species_list.append(seal)
	
	var pangolin = AnimalSpeciesClass.new()
	pangolin.species_name = "Pangolin"
	pangolin.description = "独特的鳞甲哺乳动物。"
	pangolin.is_clean = false
	pangolin.diet = AnimalSpeciesClass.Diet.CARNIVORE
	pangolin.base_width_cubits = 3.0
	pangolin.base_weight = 1.5
	pangolin.placement_faith_cost = 1.5
	pangolin.visual_color = Color(0.45, 0.4, 0.35)
	species_list.append(pangolin)
	
	var anteater = AnimalSpeciesClass.new()
	anteater.species_name = "Anteater"
	anteater.description = "以蚂蚁为食的奇特动物。"
	anteater.is_clean = false
	anteater.diet = AnimalSpeciesClass.Diet.CARNIVORE
	anteater.base_width_cubits = 5.0
	anteater.base_weight = 2.5
	anteater.placement_faith_cost = 1.8
	anteater.visual_color = Color(0.45, 0.4, 0.35)
	species_list.append(anteater)
	
	var tapir = AnimalSpeciesClass.new()
	tapir.species_name = "Tapir"
	tapir.description = "形状奇特的有蹄动物。"
	tapir.is_clean = false
	tapir.base_width_cubits = 5.0
	tapir.base_weight = 3.5
	tapir.placement_faith_cost = 1.8
	tapir.visual_color = Color(0.25, 0.25, 0.3)
	species_list.append(tapir)