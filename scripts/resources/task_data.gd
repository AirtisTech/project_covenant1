extends Resource
class_name TaskData

enum Type {
	IDLE,
	CLEAN,
	FEED,
	REPAIR,
	COLLECT_WOOD, # 砍树
	PROCESS_WOOD, # 在地面对倒下的树进行加工
	HAUL_WOOD,    # 搬运木材堆
	COLLECT_PITCH, # 采集松香
	PROCESS_PITCH, # 加工/装桶松香
	HAUL_PITCH,   # 搬运松香
	COMFORT,
	SLAUGHTER
}

@export var type: Type = Type.IDLE
@export var position: Vector2 = Vector2.ZERO
@export var priority: int = 1 # 1 为最高

var target_node: Node = null # 任务关联的对象
var assigned_agent: Node = null # 已指派的成员

func _init(p_type: Type = Type.IDLE, p_pos: Vector2 = Vector2.ZERO, p_priority: int = 1, p_target: Node = null):
	type = p_type
	position = p_pos
	priority = p_priority
	target_node = p_target
