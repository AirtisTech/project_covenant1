extends Node

# 预加载类
const TaskDataClass = preload("res://scripts/resources/task_data.gd")

var pending_tasks: Array = []
var active_tasks: Array = []

signal task_added(task)
signal task_started(task, agent: Node)
signal task_completed(task)

func add_task(type, pos: Vector2, priority: int = 1, target: Node = null):
	var new_task = TaskDataClass.new(type, pos, priority, target)
	pending_tasks.append(new_task)
	pending_tasks.sort_custom(func(a, b): return a.priority < b.priority)
	task_added.emit(new_task)
	return new_task

func request_task(agent: Node, allowed_types: Array) -> TaskDataClass:
	if pending_tasks.is_empty():
		return null
	var best_task = null
	for i in range(pending_tasks.size()):
		var task = pending_tasks[i]
		if task.type in allowed_types:
			best_task = task
			pending_tasks.remove_at(i)
			break
	if best_task:
		best_task.assigned_agent = agent
		active_tasks.append(best_task)
		task_started.emit(best_task, agent)
	return best_task

# --- 核心交互修复：手动指派特定任务 ---
func assign_specific_task(agent: Node, target_node: Node) -> bool:
	# 寻找关联到该物体的任务
	for i in range(pending_tasks.size()):
		var task = pending_tasks[i]
		if task.target_node == target_node:
			# 从待处理中移除，直接给这个 Agent
			pending_tasks.remove_at(i)
			task.assigned_agent = agent
			active_tasks.append(task)
			if agent.has_method("force_task"):
				agent.force_task(task)
			return true
	return false

func complete_task(task):
	if active_tasks.has(task):
		active_tasks.erase(task)
		task_completed.emit(task)

func cancel_task(task):
	if pending_tasks.has(task):
		pending_tasks.erase(task)
	elif active_tasks.has(task):
		active_tasks.erase(task)
