extends Control

@onready var day_label = $VBoxContainer/DayLabel
@onready var res_label = $VBoxContainer/ResourceLabel
@onready var start_button = $StartButton
var flood_label: Label

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
	
	# 显示洪水信息
	_update_flood_display()

func _update_flood_display():
	var pm = get_node_or_null("/root/PhaseManager")
	if pm and pm.current_phase == pm.Phase.DELUGE:
		flood_label.visible = true
		var weather = "🌊 平静" if not pm.is_storming else "🌧️ 暴风雨!"
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
