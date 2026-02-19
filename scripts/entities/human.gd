extends CharacterBody2D

# 预加载
const TaskDataClass = preload("res://scripts/resources/task_data.gd")

@export var move_speed: float = 120.0
@export var agent_name: String = "Noah"

# 体力系统
var stamina: float = 100.0
const STAMINA_DRAIN_RATE = 5.0
const STAMINA_RECOVERY_RATE = 2.0

enum State { IDLE, MOVING, WORKING, EXHAUSTED, RESTING, PLAYER_ASSIGNED }
var current_state: State = State.IDLE

var current_task = null
var player_assigned_task: bool = false  # 是否是玩家指派的任务
var current_path: PackedVector2Array = []
var selection_visual: ColorRect
var stamina_bar: ColorRect 
var target_position: Vector2 = Vector2.ZERO

var current_deck: int = 1  # 当前所在的甲板层 (0=底层, 1=中层, 2=上层)
var target_deck: int = 1  # 目标甲板层
var is_using_stairs: bool = false  # 是否正在使用楼梯

# 休息点
var rest_position: Vector2 = Vector2(100, 340)

func _ready():
	add_to_group("agents")
	_setup_visuals()

func _setup_visuals():
	# 身体 - 调整为与甲板楼层比例适当的大小
	var body = ColorRect.new()
	body.size = Vector2(16, 18)  # 原来是 24x34，太大
	body.position = Vector2(-8, -18)
	body.color = Color.RED
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(body)
	
	# 点击探测区
	var area = Area2D.new()
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(30, 40)  # 缩小碰撞区
	col.shape = shape
	area.add_child(col)
	add_child(area)
	area.input_event.connect(_on_input_event)
	
	# 选中视觉
	selection_visual = ColorRect.new()
	selection_visual.size = Vector2(20, 4)
	selection_visual.position = Vector2(-10, 8)
	selection_visual.color = Color.CYAN
	selection_visual.visible = false
	add_child(selection_visual)
	
	# 体力条
	var bar_bg = ColorRect.new()
	bar_bg.size = Vector2(20, 3)
	bar_bg.position = Vector2(-10, -24)
	bar_bg.color = Color.BLACK
	add_child(bar_bg)
	
	stamina_bar = ColorRect.new()
	stamina_bar.size = Vector2(20, 3)
	stamina_bar.position = Vector2(-10, -24)
	stamina_bar.color = Color.GREEN
	add_child(stamina_bar)
	
	var label = Label.new()
	label.text = agent_name
	label.position = Vector2(-12, -38)
	label.add_theme_font_size_override("font_size", 10)  # 缩小字体
	add_child(label)

func _on_input_event(_viewport, event, _idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var sm = get_node_or_null("/root/SelectionManager")
		if sm: sm.call("select_agent", self)
		get_viewport().set_input_as_handled()

func set_selection(is_selected: bool):
	selection_visual.visible = is_selected

# 玩家指派任务
func assign_task(task_type, target_pos: Vector2):
	current_task = TaskDataClass.new(task_type, target_pos, 1, null, "veg")
	player_assigned_task = true
	target_position = target_pos
	current_state = State.MOVING
	print("📋 玩家指派任务给 ", agent_name, ": ", task_type)

func _physics_process(delta):
	_update_stamina(delta)
	match current_state:
		State.IDLE: _handle_idle()
		State.MOVING: _move_to_target(delta)
		State.WORKING: _do_work(delta)
		State.EXHAUSTED: _handle_exhaustion()
		State.RESTING: _handle_resting(delta)
		State.PLAYER_ASSIGNED: _move_to_target(delta)

func _update_stamina(delta):
	if current_state == State.WORKING:
		stamina = stamina - (STAMINA_DRAIN_RATE * delta)
	elif current_state == State.MOVING:
		stamina = stamina - (STAMINA_DRAIN_RATE * 0.5 * delta)
	else:
		stamina = stamina + (STAMINA_RECOVERY_RATE * delta)
	
	stamina = clamp(stamina, 0, 100)
	stamina_bar.size = Vector2((stamina / 100.0) * 30.0, 4)
	stamina_bar.color = Color.GREEN.lerp(Color.RED, 1.0 - (stamina / 100.0))
	
	if stamina <= 0 and current_state != State.EXHAUSTED:
		_go_to_rest()

func _handle_idle():
	if stamina > 30.0:
		_seek_task()
	else:
		current_state = State.RESTING

func _seek_task():
	var tm = get_node_or_null("/root/TaskManager")
	if tm:
		# 先尝试获取系统任务
		current_task = tm.call("request_task", self, []) 
		if current_task:
			var gm = get_node_or_null("/root/GameManager")
			if gm and gm.get("ark_system"):
				target_position = current_task.position
				current_state = State.MOVING
				return
	
	# 没有任务时，自动寻找工作
	_auto_find_work()

func _auto_find_work():
	# 优先级：1. 喂饥饿的动物 2. 清理 3. 修理 4. 休息
	var survival = get_node_or_null("/root/AnimalSurvival")
	
	# 1. 检查有没有饥饿的动物需要喂
	if survival:
		var hungry_animals = survival.get_hungry_animals()
		if not hungry_animals.is_empty():
			var animal = hungry_animals[0]
			var species = animal.get_meta("species")
			var food_type = "veg"
			if species and species.diet == 1:
				food_type = "meat"
			
			current_task = TaskDataClass.new(TaskDataClass.Type.FEED, animal.global_position, 1, animal, food_type)
			target_position = animal.global_position
			current_state = State.MOVING
			player_assigned_task = false
			print("🤖 ", agent_name, " 自动去寻找饥饿的动物")
			return
	
	# 2. 随机进行清理或修理
	if randf() < 0.5:
		current_task = TaskDataClass.new(TaskDataClass.Type.CLEAN, global_position + Vector2(randf_range(-50, 50), 0))
	else:
		current_task = TaskDataClass.new(TaskDataClass.Type.REPAIR, global_position + Vector2(randf_range(-50, 50), 0))
	
	target_position = current_task.position
	current_state = State.MOVING
	player_assigned_task = false
	print("🤖 ", agent_name, " 自动开始工作")

func _move_to_target(delta):
	var direction = (target_position - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()
	
	if global_position.distance_to(target_position) < 10.0:
		velocity = Vector2.ZERO
		current_state = State.WORKING

func _do_work(_delta):
	if current_task:
		match current_task.type:
			TaskDataClass.Type.FEED:
				_do_feeding()
			TaskDataClass.Type.CLEAN:
				_do_cleaning()
			TaskDataClass.Type.REPAIR:
				_do_repair()
			_:
				_complete_task()

func _do_feeding():
	var target = current_task.target_node
	var food_type = current_task.food_type if current_task else "veg"
	
	if target and is_instance_valid(target):
		var species = target.get_meta("species")
		if species:
			var gm = get_node_or_null("/root/GameManager")
			if gm:
				# 检查是否有正确的食物
				var consumed = false
				if food_type == "veg" or food_type == "any":
					if gm.consume_resource("veg", 2.0):
						consumed = true
						_finish_feeding(target, 30)
				elif food_type == "meat":
					if gm.consume_resource("meat", 2.0):
						consumed = true
						_finish_feeding(target, 30)
				
				if not consumed:
					print("❌ 没有足够的食物！")
	
	_complete_task()

func _finish_feeding(target, hunger_reduction):
	if target and is_instance_valid(target):
		var hunger = target.get_meta("hunger", 0.0)
		hunger = max(0, hunger - hunger_reduction)
		target.set_meta("hunger", hunger)
		print("🍎 ", agent_name, " 喂食成功！动物饥饿值: ", hunger)

func _do_cleaning():
	print("🧹 ", agent_name, " 正在清理")
	_complete_task()

func _do_repair():
	print("🔧 ", agent_name, " 正在修理")
	_complete_task()

func _complete_task():
	var tm = get_node_or_null("/root/TaskManager")
	if tm and current_task:
		tm.call("complete_task", current_task)
	current_task = null
	current_state = State.IDLE

func _go_to_rest():
	current_state = State.RESTING
	current_task = null
	target_position = rest_position
	print("💤 ", agent_name, " 累了，需要休息")

func _handle_resting(delta):
	if stamina >= 100.0:
		current_state = State.IDLE
		print("💪 ", agent_name, " 休息好了")
		return
	
	# 走向休息点
	if global_position.distance_to(rest_position) > 10.0:
		var direction = (rest_position - global_position).normalized()
		velocity = direction * move_speed * 0.5
		move_and_slide()
	else:
		# 在休息点恢复体力
		pass

func _handle_exhaustion():
	velocity = Vector2.ZERO
	if stamina >= 50.0:
		current_state = State.IDLE

func move_to(pos: Vector2):
	current_task = null
	target_position = pos
	current_state = State.MOVING
	
	# 检查是否需要换层
	var ark = get_ark_system()
	if ark:
		var current_y = global_position.y
		var target_y = pos.y
		
		current_deck = ark.get_deck_at_y(current_y)
		target_deck = ark.get_deck_at_y(target_y)
		
		# 如果需要换层，计算经过楼梯的路径
		if current_deck != target_deck and current_deck != -1 and target_deck != -1:
			_calculate_path_with_stairs(pos, current_deck, target_deck, ark)
		else:
			# 同一层，直接移动
			pass
	
	print("🏃 ", agent_name, " 前往 ", pos)

func get_ark_system():
	var root = get_tree().root
	if root:
		return root.find_child("ArkSystem", true, false)
	return null

func _calculate_path_with_stairs(target_pos: Vector2, from_deck: int, to_deck: int, ark):
	# 计算经过楼梯的路径
	var stairs_pos = ark.get_stairs_in_range(from_deck, to_deck)
	
	if stairs_pos.x > 0:
		# 路径：当前位置 -> 楼梯 -> 目标位置
		var deck_y = ark.get_deck_target_y(to_deck)
		target_position = Vector2(stairs_pos.x, deck_y)
		
		# 标记即将使用楼梯
		print("🪜 ", agent_name, " 需要使用楼梯从 ", from_deck, " 层到 ", to_deck, " 层")
