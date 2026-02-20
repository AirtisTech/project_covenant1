extends Control

# 角色信息面板 - 显示选中角色的状态和任务队列

var selected_agent: Node = null
var panel_bg: Panel
var name_label: Label
var stamina_label: Label
var task_label: Label
var task_queue_label: Label
var animal_count_label: Label
var building_count_label: Label

const PANEL_WIDTH = 200
const PANEL_HEIGHT = 180

func _ready():
	_setup_ui()
	visible = false

func _setup_ui():
	# 背景面板
	panel_bg = Panel.new()
	panel_bg.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	panel_bg.offset_left = -PANEL_WIDTH - 20
	panel_bg.offset_top = 20
	panel_bg.offset_right = -20
	panel_bg.offset_bottom = PANEL_HEIGHT + 20
	add_child(panel_bg)
	
	# 角色名称
	name_label = Label.new()
	name_label.position = Vector2(10, 10)
	name_label.text = "未选中角色"
	panel_bg.add_child(name_label)
	
	# 体力条
	stamina_label = Label.new()
	stamina_label.position = Vector2(10, 35)
	stamina_label.text = "体力: 100%"
	stamina_label.add_theme_font_size_override("font_size", 12)
	panel_bg.add_child(stamina_label)
	
	# 当前任务
	task_label = Label.new()
	task_label.position = Vector2(10, 55)
	task_label.text = "当前: 无"
	task_label.add_theme_font_size_override("font_size", 12)
	panel_bg.add_child(task_label)
	
	# 任务队列
	task_queue_label = Label.new()
	task_queue_label.position = Vector2(10, 75)
	task_queue_label.text = "队列: 空"
	task_queue_label.add_theme_font_size_override("font_size", 11)
	panel_bg.add_child(task_queue_label)
	
	# 分隔线
	var sep = Label.new()
	sep.position = Vector2(10, 100)
	sep.text = "────────────"
	panel_bg.add_child(sep)
	
	# 动物数量
	animal_count_label = Label.new()
	animal_count_label.position = Vector2(10, 115)
	animal_count_label.text = "🦌 动物: 0"
	animal_count_label.add_theme_font_size_override("font_size", 12)
	panel_bg.add_child(animal_count_label)
	
	# 建筑数量
	building_count_label = Label.new()
	building_count_label.position = Vector2(10, 135)
	building_count_label.text = "🏠 建筑: 0"
	building_count_label.add_theme_font_size_override("font_size", 12)
	panel_bg.add_child(building_count_label)

func _process(_delta):
	# 更新选中角色信息
	if selected_agent and is_instance_valid(selected_agent):
		_update_agent_info()
	
	# 更新全局统计
	_update_stats()

func _update_agent_info():
	if not selected_agent:
		return
	
	# 名称 - 直接访问属性
	if "agent_name" in selected_agent:
		name_label.text = "👤 " + str(selected_agent.agent_name)
	
	# 体力 - 直接访问属性
	if "stamina" in selected_agent:
		var stamina = selected_agent.stamina
		var color = "🟢" if stamina > 50 else "🟡" if stamina > 20 else "🔴"
		stamina_label.text = "%s 体力: %d%%" % [color, int(stamina)]
	
	# 当前任务 - 直接访问属性
	if "current_task" in selected_agent and selected_agent.current_task:
		var task = selected_agent.current_task
		var task_name = "工作中"
		match task.type:
			1: task_name = "🧹 清理"
			2: task_name = "🍎 喂食"
			3: task_name = "🔧 修理"
			_: task_name = "工作中"
		task_label.text = "📌 " + task_name
	else:
		task_label.text = "📌 待机中"
	
	# 任务队列
	if "task_queue" in selected_agent:
		var queue_size = selected_agent.task_queue.size()
		if queue_size > 0:
			task_queue_label.text = "📋 队列: %d 个任务" % queue_size
		else:
			task_queue_label.text = "📋 队列: 空"

func _update_stats():
	# 动物数量 - 简化版，直接获取
	var animal_count = 0
	var survival = get_node_or_null("/root/AnimalSurvival")
	if survival:
		var animals_list = survival.animals if "animals" in survival else []
		animal_count = animals_list.size()
	animal_count_label.text = "🦌 动物: %d" % animal_count
	
	# 建筑数量
	var building_count = 0
	building_count_label.text = "🏠 建筑: 0"

func set_selected_agent(agent: Node):
	selected_agent = agent
	visible = agent != null

func clear_selection():
	selected_agent = null
	visible = false
