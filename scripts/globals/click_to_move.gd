extends Node

# 点击移动系统
# 实现类似模拟人生的点击选择和移动控制（支持鼠标和触屏）

var selected_agent: Node = null
var last_touch_pos: Vector2 = Vector2.ZERO

func _ready():
	print("👆 ClickToMoveSystem initialized")

func _input(event):
	# 鼠标左键
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_click(event.position, event.global_position)
		
		# 右键取消选择
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_deselect_all()
	
	# 触屏点击
	if event is InputEventScreenTouch:
		if event.pressed:
			_handle_click(event.position, event.global_position)
		else:
			# 触屏释放
			last_touch_pos = Vector2.ZERO
	
	# 触屏拖拽（移动端地图平移）
	if event is InputEventScreenDrag:
		# 如果没有选中角色，拖拽用于移动地图（由 camera 处理）
		# 这里可以添加其他拖拽逻辑
		pass

func _handle_click(screen_pos: Vector2, global_pos: Vector2 = Vector2.ZERO):
	# 先检测是否点击了某个角色
	var clicked_agent = _get_agent_at_position(screen_pos)
	
	if clicked_agent:
		# 点击了角色，选中它
		_select_agent(clicked_agent)
		# 震动反馈
		_trigger_haptic("light")
		return
	
	# 如果有选中的角色，点击地面则移动过去
	if selected_agent and is_instance_valid(selected_agent):
		_move_agent_to(selected_agent, screen_pos)
		# 轻微震动
		_trigger_haptic("light")

func _get_agent_at_position(screen_pos: Vector2) -> Node:
	var fm = get_node_or_null("/root/FamilyManager")
	if not fm:
		return null
	
	for member in fm.get_family_members():
		if is_instance_valid(member):
			var camera = get_viewport().get_camera_2d()
			if camera:
				var screen_pos_of_agent = member.get_global_transform_with_canvas().origin
				# 触屏需要更大的点击范围
				var touch_range = 50
				if screen_pos.distance_to(screen_pos_of_agent) < touch_range:
					return member
	return null

func _select_agent(agent: Node):
	_deselect_all()
	
	selected_agent = agent
	if agent.has_method("set_selection"):
		agent.set_selection(true)
	
	print("👆 Selected: ", agent.agent_name)

func _deselect_all():
	if selected_agent and is_instance_valid(selected_agent):
		if selected_agent.has_method("set_selection"):
			selected_agent.set_selection(false)
	selected_agent = null

func _move_agent_to(agent: Node, screen_pos: Vector2):
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	var world_pos = get_viewport().get_canvas_transform().affine_inverse() * screen_pos
	
	if agent.has_method("move_to"):
		agent.move_to(world_pos)
		print("👆 ", agent.agent_name, " moving to ", world_pos)

func _trigger_haptic(type: String = "light"):
	# 调用 HapticManager
	var hm = get_node_or_null("/root/HapticManager")
	if hm:
		match type:
			"light":
				if hm.has_method("light"):
					hm.light()
			"medium":
				if hm.has_method("medium"):
					hm.medium()
			"heavy":
				if hm.has_method("heavy"):
					hm.heavy()
