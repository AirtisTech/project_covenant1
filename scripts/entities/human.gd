extends CharacterBody2D

# 预加载
const TaskDataClass = preload("res://scripts/resources/task_data.gd")

@export var move_speed: float = 120.0
@export var agent_name: String = "Noah"

# 体力系统
var stamina: float = 100.0
const STAMINA_DRAIN_RATE = 5.0
const STAMINA_RECOVERY_RATE = 2.0

enum State { IDLE, MOVING, WORKING, EXHAUSTED, RESTING }
var current_state: State = State.IDLE

var current_task = null
var current_path: PackedVector2Array = []
var selection_visual: ColorRect
var stamina_bar: ColorRect 
var target_position: Vector2 = Vector2.ZERO

# 休息点
var rest_position: Vector2 = Vector2(100, 400)

func _ready():
	add_to_group("agents")
	_setup_visuals()

func _setup_visuals():
	# 身体
	var body = ColorRect.new()
	body.size = Vector2(24, 34)
	body.position = Vector2(-12, -27)
	body.color = Color.RED
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(body)
	
	# 点击探测区
	var area = Area2D.new()
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(50, 70)
	col.shape = shape
	area.add_child(col)
	add_child(area)
	area.input_event.connect(_on_input_event)
	
	# 选中视觉
	selection_visual = ColorRect.new()
	selection_visual.size = Vector2(30, 6)
	selection_visual.position = Vector2(-15, 12)
	selection_visual.color = Color.CYAN
	selection_visual.visible = false
	add_child(selection_visual)
	
	# 体力条
	var bar_bg = ColorRect.new()
	bar_bg.size = Vector2(30, 4)
	bar_bg.position = Vector2(-15, -35)
	bar_bg.color = Color.BLACK
	add_child(bar_bg)
	
	stamina_bar = ColorRect.new()
	stamina_bar.size = Vector2(30, 4)
	stamina_bar.position = Vector2(-15, -35)
	stamina_bar.color = Color.GREEN
	add_child(stamina_bar)
	
	var label = Label.new()
	label.text = agent_name
	label.position = Vector2(-20, -60)
	add_child(label)

func _on_input_event(_viewport, event, _idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var sm = get_node_or_null("/root/SelectionManager")
		if sm: sm.call("select_agent", self)
		get_viewport().set_input_as_handled()

func set_selection(is_selected: bool):
	selection_visual.visible = is_selected

func _physics_process(delta):
	_update_stamina(delta)
	match current_state:
		State.IDLE: _handle_idle()
		State.MOVING: _move_to_target(delta)
		State.WORKING: _do_work(delta)
		State.EXHAUSTED: _handle_exhaustion()
		State.RESTING: _handle_resting(delta)

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
		current_task = tm.call("request_task", self, []) 
		var gm = get_node_or_null("/root/GameManager")
		if current_task and gm and gm.get("ark_system"):
			target_position = current_task.position
			current_state = State.MOVING

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
	if target and is_instance_valid(target):
		var species = target.get_meta("species")
		if species:
			var food_type = "veg"
			if species.diet == 1:
				food_type = "meat"
			
			var survival = get_node_or_null("/root/AnimalSurvival")
			if survival:
				survival.feed_animal(target, food_type)
				print("🍖 ", agent_name, " 喂食了 ", species.species_name)
	
	_complete_task()

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
	print("🏃 ", agent_name, " 前往 ", pos)
