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

func _process(_delta):
	var gm = get_node_or_null("/root/GameManager")
	if not gm: return
	
	var phase_idx = gm.get("current_phase")
	var phase_name = "布局阶段"
	if phase_idx == 1: phase_name = "大洪水阶段"
	elif phase_idx == 2: phase_name = "漂流阶段"
	
	day_label.text = "天数: %d | %s" % [gm.get("day"), phase_name]
	
	var veg = gm.get("veg_rations")
	var meat = gm.get("meat_rations")
	var faith = gm.get("faith")
	res_label.text = "🍎素食: %d | 🥩肉类: %d | ❤️信心: %d%%" % [veg, meat, faith]
	
	# 布局完成后隐藏启动按钮
	if phase_idx != 0:
		start_button.visible = false
	
	# 显示洪水信息
	_update_flood_display()

func _update_flood_display():
	var pm = get_node_or_null("/root/PhaseManager")
	if pm and pm.current_phase == pm.Phase.DELUGE:
		flood_label.visible = true
		var level = int(pm.flood_water_level * 100)
		var weather = "🌊 平静" if not pm.is_storming else "🌧️ 暴风雨!"
		flood_label.text = "🌊 水位: %d%% | %s" % [level, weather]
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
