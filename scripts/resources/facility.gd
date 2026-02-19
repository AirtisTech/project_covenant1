extends Resource
class_name Facility

enum FacilityType { ANIMAL_PEN, KITCHEN, BEDROOM, FOOD_STORAGE, WATER_TANK, MEDICAL_BAY, WORKSHOP }

@export var facility_name: String = ""
@export var description: String = ""
@export var type: FacilityType = FacilityType.ANIMAL_PEN

# 尺寸（格子数）
@export var width_cells: int = 2
@export var height_cells: int = 1

# 需要的信仰值
@export var faith_cost: float = 1.0

# 是否已放置
var is_placed: bool = false

# 视觉颜色
@export var visual_color: Color = Color.WHITE

# 功能参数
@export var capacity: int = 0  # 容量（如可容纳多少动物）
@export var resource_production: float = 0.0  # 资源生产速度
