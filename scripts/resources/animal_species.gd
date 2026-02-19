extends Resource
class_name AnimalSpecies

enum Diet { HERBIVORE, CARNIVORE, OMNIVORE }

@export var species_name: String = ""
@export var description: String = ""
@export var is_clean: bool = true
@export var diet: Diet = Diet.HERBIVORE

# 单只规格
@export var base_weight: float = 1.0 
@export var base_width_cubits: float = 2.0
@export var placement_faith_cost: float = 5.0 

# --- 核心：指派状态 ---
var is_placed: bool = false # 是否已在方舟上

var width_in_cells: int:
	get:
		var total_cubits = base_width_cubits * (14.0 if is_clean else 2.0)
		return int(ceil(total_cubits / 5.0))

var weight: float:
	get:
		return base_weight * (14.0 if is_clean else 2.0)

@export var visual_color: Color = Color.WHITE
