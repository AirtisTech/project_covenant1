extends Control

# 测试按钮 - 用于快速测试 Phase 2
# 正式版可以删除或隐藏

var test_btn: Button

func _ready():
	# 创建测试按钮
	test_btn = Button.new()
	test_btn.text = "⏩ 测试: 跳到大洪水"
	test_btn.position = Vector2(10, 10)
	test_btn.pressed.connect(_on_test_pressed)
	add_child(test_btn)
	
	# 还要一个前进一天的按钮
	var day_btn = Button.new()
	day_btn.text = "📅 前进一天"
	day_btn.position = Vector2(10, 45)
	day_btn.pressed.connect(_on_day_pressed)
	add_child(day_btn)

func _on_test_pressed():
	# 直接跳到大洪水阶段
	PhaseManager.current_phase = PhaseManager.Phase.DELUGE
	PhaseManager.current_day = 1
	PhaseManager._start_flood()
	PhaseManager.phase_changed.emit(PhaseManager.Phase.PREPARATION, PhaseManager.Phase.DELUGE)
	test_btn.visible = false
	print("🌊 JUMPED TO FLOOD PHASE!")

func _on_day_pressed():
	PhaseManager.advance_day()
