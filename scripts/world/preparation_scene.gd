extends Node2D

@onready var ark_system = get_tree().get_first_node_in_group("ark_system")

const FOREST_X = 150.0
const PITCH_X = 1100.0

func _ready():
	_setup_background_catcher()
	_setup_construction_site()
	_setup_forest()
	_setup_pitch_source()

# 核心修复：创建一个全屏背景拦截器
func _setup_background_catcher():
	var canvas = CanvasLayer.new()
	canvas.layer = -1 # 确保在所有 UI 和 物体之下
	add_child(canvas)
	
	var bg_btn = Button.new()
	bg_btn.flat = true
	bg_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg_btn.mouse_filter = Control.MOUSE_FILTER_PASS # 允许点击穿透到 Area2D
	canvas.add_child(bg_btn)
	
	# 当这个背景被点击，说明玩家没点中任何角色或资源
	bg_btn.pressed.connect(func():
		SelectionManager.deselect_agent()
	)

func _setup_construction_site():
	var site = ColorRect.new()
	site.size = Vector2(120, 40)
	site.position = Vector2(640 - 60, 300 - 20)
	site.color = Color(0.5, 0.5, 0.5, 0.4)
	site.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(site)
	var label = Label.new()
	label.text = "方舟建造现场"
	label.position = Vector2(640 - 50, 300 - 15)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)

func _on_object_clicked(target: Node, event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var agent = SelectionManager.selected_agent
		if agent and is_instance_valid(agent):
			# 核心：在指派前再次确认 agent 状态
			var success = TaskManager.assign_specific_task(agent, target)
			if success:
				print("--- 指派成功: ", agent.agent_name, " -> ", target.name, " ---")
				# 拦截该事件，不传给底层的背景板
				get_viewport().set_input_as_handled()
		else:
			print("--- 调试: 点中了 ", target.name, "，但当前 selected_agent 为空 ---")

func _add_click_area(parent: Node2D):
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(80, 120)
	collision.shape = shape
	area.add_child(collision)
	parent.add_child(area)
	# 设置较低的优先级
	area.z_index = 10
	area.input_pickable = true
	area.input_event.connect(func(_vp, event, _idx): _on_object_clicked(parent, event))

# --- 资源生成逻辑 (保持稳定) ---
func _setup_forest():
	for i in 3:
		var tree_pos = Vector2(FOREST_X + i * 80, 300)
		_create_tree_visual(tree_pos, 0.4)
		_spawn_active_tree(tree_pos)

func _spawn_active_tree(pos: Vector2):
	var tree = _create_tree_visual(pos, 1.0)
	tree.name = "Tree_" + str(int(pos.x))
	TaskManager.add_task(TaskData.Type.COLLECT_WOOD, tree.global_position, 2, tree)

func _create_tree_visual(pos: Vector2, brightness: float = 1.0) -> Node2D:
	var tree_root = Node2D.new()
	tree_root.position = pos
	add_child(tree_root)
	var trunk = ColorRect.new()
	trunk.name = "Trunk"
	trunk.size = Vector2(8, 40)
	trunk.position = Vector2(-4, -40)
	trunk.color = Color.BROWN * brightness
	trunk.pivot_offset = Vector2(4, 40)
	trunk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tree_root.add_child(trunk)
	var canopy = ColorRect.new()
	canopy.name = "Canopy"
	canopy.size = Vector2(30, 30)
	canopy.position = Vector2(-11, -30) 
	canopy.color = Color.DARK_GREEN * brightness
	canopy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	trunk.add_child(canopy)
	if brightness == 1.0: _add_click_area(tree_root)
	return tree_root

func _create_wood_pile(pos: Vector2):
	var pile = Node2D.new()
	pile.name = "WoodPile_" + str(int(pos.x))
	pile.position = pos
	add_child(pile)
	for i in 3:
		var wood_log = ColorRect.new()
		wood_log.size = Vector2(16, 8)
		wood_log.position = Vector2(-8, -8 - i * 5)
		wood_log.color = Color.BROWN
		wood_log.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pile.add_child(wood_log)
	_add_click_area(pile)
	TaskManager.add_task(TaskData.Type.HAUL_WOOD, pos, 3, pile)

func _setup_pitch_source():
	for i in 2:
		var pos = Vector2(PITCH_X + i * 60, 300)
		_create_pitch_tree_visual(pos, 0.4)
		_spawn_active_pitch_tree(pos)

func _spawn_active_pitch_tree(pos: Vector2):
	var tree = _create_pitch_tree_visual(pos, 1.0)
	tree.name = "PitchTree_" + str(int(pos.x))
	TaskManager.add_task(TaskData.Type.COLLECT_PITCH, tree.global_position, 2, tree)

func _create_pitch_tree_visual(pos: Vector2, brightness: float = 1.0) -> Node2D:
	var tree = Node2D.new()
	tree.position = pos
	add_child(tree)
	var trunk = ColorRect.new()
	trunk.name = "Trunk"
	trunk.size = Vector2(6, 30)
	trunk.position = Vector2(-3, -30)
	trunk.color = Color.GRAY * brightness
	trunk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tree.add_child(trunk)
	var bucket = ColorRect.new()
	bucket.size = Vector2(12, 12)
	bucket.position = Vector2(-6, -15)
	bucket.color = Color.BLUE * brightness
	bucket.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tree.add_child(bucket)
	if brightness == 1.0: _add_click_area(tree)
	return tree

func _create_pitch_pile(pos: Vector2):
	var container = Node2D.new()
	container.name = "PitchPile_" + str(int(pos.x))
	container.position = pos
	add_child(container)
	var pile = ColorRect.new()
	pile.size = Vector2(14, 14)
	pile.position = Vector2(-7, -7)
	pile.color = Color.BLUE
	pile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.add_child(pile)
	_add_click_area(container)
	TaskManager.add_task(TaskData.Type.HAUL_PITCH, pos, 3, container)