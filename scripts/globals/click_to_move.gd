extends Node

# 点击移动系统
# 实现类似模拟人生的点击选择和移动控制

var selected_agent: Node = null

func _ready():
	print("👆 ClickToMoveSystem initialized")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_click(event.position)
	
	# 右键取消选择
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_deselect_all()

func _handle_click(screen_pos: Vector2):
	# 先检测是否点击了某个角色
	var clicked_agent = _get_agent_at_position(screen_pos)
	
	if clicked_agent:
		# 点击了角色，选中它
		_select_agent(clicked_agent)
		return
	
	# 如果有选中的角色，点击地面则移动过去
	if selected_agent and is_instance_valid(selected_agent):
		_move_agent_to(selected_agent, screen_pos)

func _get_agent_at_position(screen_pos: Vector2) -> Node:
	var fm = get_node_or_null("/root/FamilyManager")
	if not fm:
		return null
	
	for member in fm.get_family_members():
		if is_instance_valid(member):
			# 将角色的世界坐标转换为屏幕坐标
			var camera = get_viewport().get_camera_2d()
			if camera:
				var screen_pos_of_agent = camera.unproject(member.global_position)
				# 检测点击是否在角色附近（50像素范围内）
				if screen_pos.distance_to(screen_pos_of_agent) < 40:
					return member
	return null

func _select_agent(agent: Node):
	# 取消之前的选择
	_deselect_all()
	
	# 选中新角色
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
	# 将屏幕坐标转换为世界坐标
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	var world_pos = camera.get_global_transform().affine_inverse() * screen_pos
	
	# 调用角色的移动方法
	if agent.has_method("move_to"):
		agent.move_to(world_pos)
		print("👆 ", agent.agent_name, " moving to ", world_pos)
