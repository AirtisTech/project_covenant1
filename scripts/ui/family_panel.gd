extends Control

# 家庭成员状态面板
# 显示所有家庭成员的状态

var family_container: VBoxContainer
var update_timer: float = 0.0

func _ready():
	visible = false
	_setup_ui()
	
	# 连接阶段变化信号
	var pm = get_node_or_null("/root/PhaseManager")
	if pm:
		pm.phase_changed.connect(_on_phase_changed)

func _setup_ui():
	# 背景面板
	var panel = Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	panel.offset_left = -220
	panel.offset_top = 10
	panel.offset_right = -10
	panel.offset_bottom = 200
	add_child(panel)
	
	var title = Label.new()
	title.text = "👨‍👩‍👦‍👦 家庭成员"
	title.position = Vector2(10, 5)
	title.add_theme_font_size_override("font_size", 14)
	panel.add_child(title)
	
	family_container = VBoxContainer.new()
	family_container.position = Vector2(10, 30)
	family_container.size = Vector2(200, 160)
	panel.add_child(family_container)

func _process(delta):
	update_timer += delta
	if update_timer >= 1.0:  # 每秒更新一次
		update_timer = 0.0
		_update_family_status()

func _update_family_status():
	if not visible:
		return
	
	var fm = get_node_or_null("/root/FamilyManager")
	if not fm:
		return
	
	# 清除旧内容
	for child in family_container.get_children():
		child.queue_free()
	
	# 显示每个成员状态
	for member in fm.get_family_members():
		if is_instance_valid(member):
			var status = _get_member_status(member)
			var label = Label.new()
			label.text = "• %s: %s" % [member.agent_name, status]
			label.add_theme_font_size_override("font_size", 12)
			family_container.add_child(label)

func _get_member_status(member) -> String:
	var state = member.get("current_state")
	if state == null:
		return "🟢 就绪"
	
	match state:
		0: return "🟢 就绪"
		1: return "🏃 移动中"
		2: return "🔨 工作中"
		3: return "🔴 疲惫"
		4: return "💤 休息中"
		_: return "🟡 未知"

func _on_phase_changed(from, to):
	# 在大洪水和漂流阶段显示
	var pm = get_node_or_null("/root/PhaseManager")
	if pm and (to == pm.Phase.DELUGE or to == pm.Phase.DRIFT):
		visible = true
	else:
		visible = false
