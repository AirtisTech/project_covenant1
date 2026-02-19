extends Control

# 挪亚家庭成员管理
# 生成并管理方舟上的家庭成员

var family_members: Array = []

const FAMILY_DATA = [
	{"name": "挪亚", "color": Color.RED},
	{"name": "妻子", "color": Color.PINK},
	{"name": "闪", "color": Color.ORANGE},
	{"name": "含", "color": Color.YELLOW},
	{"name": "雅弗", "color": Color.CYAN}
]

func _ready():
	_spawn_family()
	print("👨‍👩‍👦‍👦 Noah's family spawned: ", family_members.size(), " members")

func _spawn_family():
	var ark = get_tree().root.find_child("ArkSystem", true, false)
	if not ark:
		return
	
	var HumanClass = preload("res://scripts/entities/human.gd")
	
	for i in range(FAMILY_DATA.size()):
		var data = FAMILY_DATA[i]
		var human = HumanClass.new()
		human.agent_name = data["name"]
		human.position = Vector2(200 + i * 60, 350)
		
		# 设置颜色
		for child in human.get_children():
			if child is ColorRect:
				child.color = data["color"]
		
		ark.add_child(human)
		family_members.append(human)

func get_family_members() -> Array:
	return family_members
