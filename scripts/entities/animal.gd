extends Node2D

@export var species_data: AnimalSpecies

var hunger: float = 0.0
var health: float = 100.0
var panic: float = 0.0

func _ready():
	add_to_group("animals")
	if species_data:
		_setup_visual()

func _setup_visual():
	var body = ColorRect.new()
	body.size = Vector2(24, 20)
	body.position = Vector2(-12, -10)
	body.color = species_data.visual_color
	add_child(body)

func _process(delta):
	if GameManager.current_phase == GameManager.Phase.LAYOUT: return
	
	_handle_hunger(delta)
	_handle_health(delta)

func _handle_hunger(delta):
	# 饥饿增长速率
	hunger += delta * 2.0
	
	# 如果饥饿度超过阈值，尝试消耗资源
	if hunger > 50.0:
		_attempt_to_eat()

func _attempt_to_eat():
	match species_data.diet:
		AnimalSpecies.Diet.HERBIVORE:
			if GameManager.veg_rations >= 1.0:
				GameManager.veg_rations -= 1.0
				hunger = 0.0
		AnimalSpecies.Diet.CARNIVORE:
			if GameManager.meat_rations >= 1.0:
				GameManager.meat_rations -= 1.0
				hunger = 0.0
			else:
				# 没肉吃了！惊恐度暴涨
				panic += 10.0
				print(species_data.species_name + ": 极度饥饿！寻找肉食中...")
		AnimalSpecies.Diet.OMNIVORE:
			# 杂食动物优先素食，没素食吃肉
			if GameManager.veg_rations >= 1.0:
				GameManager.veg_rations -= 1.0
				hunger = 0.0
			elif GameManager.meat_rations >= 1.0:
				GameManager.meat_rations -= 1.0
				hunger = 0.0

func _handle_health(delta):
	if hunger > 100.0:
		health -= delta * 5.0 # 饥饿扣血
	
	if health <= 0:
		_die()

func _die():
	print(species_data.species_name + " 已饿死。")
	# 动物死后可以被“回收”为肉类
	GameManager.meat_rations += 20.0
	queue_free()
