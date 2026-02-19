extends Control

# 挪亚家庭成员管理
# 生成并管理方舟上的家庭成员

var family_members: Array = []

const FAMILY_DATA = [
	{"name": "挪亚", "color": Color.RED},
	{"name": "挪亚之妻", "color": Color.PINK},
	{"name": "闪", "color": Color.ORANGE},
	{"name": "闪之妻", "color": Color(1, 0.5, 0.5)},
	{"name": "含", "color": Color.YELLOW},
	{"name": "含之妻", "color": Color(0.5, 1, 0.5)},
	{"name": "雅弗", "color": Color.CYAN},
	{"name": "雅弗之妻", "color": Color(0.5, 0.5, 1)}
]

func _ready():
	# 连接到 PhaseManager，只有在洪水阶段家人才会出现在方舟上
	var pm = get_node_or_null("/root/PhaseManager")
	if pm:
		pm.entered_ark.connect(_spawn_family)
	
	print("👨‍👩‍👦‍👦 Family ready - will board ark when flood begins")

func _spawn_family():
	var ark = get_tree().root.find_child("ArkSystem", true, false)
	if not ark:
		return
	
	var HumanClass = preload("res://scripts/entities/human.gd")
	
	for i in range(FAMILY_DATA.size()):
		var data = FAMILY_DATA[i]
		var human = HumanClass.new()
		human.agent_name = data["name"]
		# 中层甲板 (index 1, Y=340)
		human.position = Vector2(200 + i * 60, 340)
		human.rest_position = Vector2(100 + i * 30, 340)  # 休息点也在中层
		
		# 设置颜色
		for child in human.get_children():
			if child is ColorRect:
				child.color = data["color"]
		
		ark.add_child(human)
		family_members.append(human)

func get_family_members() -> Array:
	return family_members
