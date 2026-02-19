extends Control

@onready var day_label = $VBoxContainer/DayLabel
@onready var res_label = $VBoxContainer/ResourceLabel
@onready var start_button = $StartButton

func _ready():
	if start_button:
		start_button.pressed.connect(_on_start_pressed)

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

func _on_start_pressed():
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.call("start_deluge_phase")
		# 隐藏底部菜单
		var selector = get_tree().root.find_child("AnimalSelector", true, false)
		if selector: selector.visible = false
		
		if get_node_or_null("/root/HapticManager"):
			get_node("/root/HapticManager").call("heavy")
