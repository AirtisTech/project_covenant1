extends Node

var selected_agent: Node = null

signal agent_selected(agent: Node)
signal agent_deselected()

func select_agent(agent: Node):
	if selected_agent == agent: return
	
	# ...
	selected_agent = agent
	if selected_agent and is_instance_valid(selected_agent):
		if selected_agent.has_method("set_selection"):
			selected_agent.set_selection(true)
		HapticManager.light() # 增加轻微震动
		print("SelectionManager: 成功锁定 ", agent.agent_name)
		agent_selected.emit(agent)

func deselect_agent():
	if selected_agent and is_instance_valid(selected_agent):
		if selected_agent.has_method("set_selection"):
			selected_agent.set_selection(false)
	selected_agent = null
	agent_deselected.emit()
	print("SelectionManager: 已手动解除选中")
