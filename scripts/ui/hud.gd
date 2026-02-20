extends Control

@onready var day_label = $VBoxContainer/DayLabel
@onready var res_label = $VBoxContainer/ResourceLabel
@onready var start_button = $StartButton
var flood_label: Label
var agent_info_panel: Control

func _ready():
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
	
	# 创建洪水显示标签
	flood_label = Label.new()
	flood_label.name = "FloodLabel"
	flood_label.position = Vector2(20, 80)
	flood_label.add_theme_color_override("font_color", Color.CYAN)
	flood_label.add_theme_font_size_override("font_size", 16)
	flood_label.visible = false
	add_child(flood_label)
	
	# 创建生存事件显示标签
	var event_label = Label.new()
	event_label.name = "EventLabel"
	event_label.position = Vector2(20, 110)
	event_label.add_theme_color_override("font_color", Color.ORANGE)
	event_label.add_theme_font_size_override("font_size", 14)
	event_label.visible = false
	add_child(event_label)
	
	# 连接生存事件信号
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.has_signal("survival_event"):
		gm.survival_event.connect(_on_survival_event)
	
	# 创建角色信息面板
	_create_agent_info_panel()
	
	# 连接选择信号
	var sm = get_node_or_null("/root/SelectionManager")
	if sm:
		sm.agent_selected.connect(_on_agent_selected)
		sm.agent_deselected.connect(_on_agent_deselected)

func _create_agent_info_panel():
	var AgentInfoPanelClass = load("res://scripts/ui/agent_info_panel.gd")
	agent_info_panel = AgentInfoPanelClass.new()
	agent_info_panel.name = "AgentInfoPanel"
	add_child(agent_info_panel)

func _on_agent_selected(agent: Node):
	if agent_info_panel:
		agent_info_panel.set_selected_agent(agent)

func _on_agent_deselected():
	if agent_info_panel:
		agent_info_panel.clear_selection()

func _process(_delta):
	var gm = get_node_or_null("/root/GameManager")
	if not gm: return
	
	var phase_idx = gm.get("current_phase")
	var phase_name = "🎯 准备阶段"
	if phase_idx == 1: phase_name = "🌊 大洪水阶段"
	elif phase_idx == 2: phase_name = "🛶 漂流阶段"
	
	# 准备阶段显示提示
	if phase_idx == 0:
		day_label.text = "准备阶段 | 规划你的方舟布局"
		day_label.tooltip_text = "点击角色可查看状态和任务队列"
	else:
		day_label.text = "天数: %d | %s" % [gm.get("day"), phase_name]
	
	var veg = gm.get("veg_rations")
	var meat = gm.get("meat_rations")
	var water = gm.get("water")
	var faith = gm.get("faith")
	res_label.text = "🍎素食: %d | 🥩肉类: %d | 💧水: %d | ❤️信心: %d%%" % [veg, meat, water, faith]
	
	# 布局完成后隐藏启动按钮
	if phase_idx != 0:
		start_button.visible = false
	
	# 漂流阶段显示距离
	if phase_idx == 2:
		var dist = 0
		if gm.has("distance_to_land"):
			dist = gm.distance_to_land
		day_label.text = "天数: %d | 🛶 距离陆地: %d km" % [gm.get("day"), dist]
	
	# 显示洪水/漂流信息
	_update_flood_display()

func _update_flood_display():
	var pm = get_node_or_null("/root/PhaseManager")
	if pm and pm.current_phase == pm.Phase.DELUGE:
		flood_label.visible = true
		var weather = "☀️ 晴朗"
		if pm.is_storming:
			if pm.weather_intensity < 0.3:
				weather = "🌤️ 多云"
			elif pm.weather_intensity < 0.6:
				weather = "🌧️ 小雨"
			elif pm.weather_intensity < 0.8:
				weather = "🌧️ 大雨"
			else:
				weather = "⛈️ 暴风雨！"
		flood_label.text = "🌊 洪水已至！| %s" % weather
	else:
		flood_label.visible = false

func _on_start_pressed():
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.call("start_deluge_phase")
		# 隐藏底部菜单
		var selector = get_tree().root.find_child("AnimalSelector", true, false)
		if selector: selector.visible = false
		
		if get_node_or_null("/root/HapticManager"):
			get_node("/root/HapticManager").call("heavy")

func _on_survival_event(message: String):
	var event_label = find_child("EventLabel", true, false)
	if event_label:
		event_label.text = message
		event_label.visible = true
		# 3秒后隐藏
		await get_tree().create_timer(3.0).timeout
		event_label.visible = false
