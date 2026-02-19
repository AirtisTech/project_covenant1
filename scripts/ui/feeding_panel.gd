extends Control

# 喂食面板 - 在大洪水阶段显示

var food_buttons_container: HBoxContainer
var status_label: Label

func _ready():
	visible = false
	
	# 创建UI
	var panel = Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.size = Vector2(400, 200)
	add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 15)
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "🍖 喂食站"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)
	
	status_label = Label.new()
	status_label.text = "选择要喂的动物"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(status_label)
	
	food_buttons_container = HBoxContainer.new()
	food_buttons_container.alignment = BoxContainer.ALIGNMENT_CENTER
	food_buttons_container.add_theme_constant_override("separation", 20)
	vbox.add_child(food_buttons_container)
	
	# 素食按钮
	var veg_btn = Button.new()
	veg_btn.text = "🥬 素食 (🍎)"
	veg_btn.pressed.connect(_on_veg_pressed)
	food_buttons_container.add_child(veg_btn)
	
	# 肉食按钮
	var meat_btn = Button.new()
	meat_btn.text = "🥩 肉食 (🥩)"
	meat_btn.pressed.connect(_on_meat_pressed)
	food_buttons_container.add_child(meat_btn)
	
	# 关闭按钮
	var close_btn = Button.new()
	close_btn.text = "关闭"
	close_btn.pressed.connect(func(): visible = false)
	vbox.add_child(close_btn)
	
	# 连接信号
	PhaseManager.phase_changed.connect(_on_phase_changed)
	AnimalSurvival.animal_hunger_changed.connect(_on_hunger_changed)

func _on_phase_changed(from, to):
	if to == PhaseManager.Phase.DELUGE or to == PhaseManager.Phase.DRIFT:
		visible = true
	else:
		visible = false

func _on_hunger_changed(animal, hunger: float):
	# 可以在这里更新状态显示
	pass

func _on_veg_pressed():
	_feed_selected_animal("veg")

func _on_meat_pressed():
	_feed_selected_animal("meat")

func _feed_selected_animal(food_type: String):
	var survival = get_node_or_null("/root/AnimalSurvival")
	if not survival:
		return
	
	# 获取饥饿的动物
	var hungry_animals = survival.get_hungry_animals()
	if hungry_animals.size() == 0:
		status_label.text = "所有动物都吃饱了！"
		return
	
	# 喂第一只饥饿的动物
	var fed = false
	for animal in hungry_animals:
		if survival.feed_animal(animal, food_type):
			fed = true
			status_label.text = "✅ 喂食成功！"
			break
	
	if not fed:
		status_label.text = "❌ 这种食物不适合它们"

func open_panel():
	visible = true
	_update_status()

func _update_status():
	var survival = get_node_or_null("/root/AnimalSurvival")
	if survival:
		var hungry = survival.get_hungry_animals().size()
		status_label.text = "饥饿动物: %d 只" % hungry
