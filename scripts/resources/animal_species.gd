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
var pair_count: int = 0  # 已放置的对数

# 需要的对数：洁净7对，不洁净1对
const CLEAN_PAIRS = 7
const UNCLEAN_PAIRS = 1

var width_in_cells: int:
	get:
		var pairs = CLEAN_PAIRS if is_clean else UNCLEAN_PAIRS
		var total_cubits = base_width_cubits * (pairs as float * 2.0)
		return int(ceil(total_cubits / 5.0))

var weight: float:
	get:
		var pairs = CLEAN_PAIRS if is_clean else UNCLEAN_PAIRS
		return base_weight * (pairs as float * 2.0)

var total_animals: int:
	get:
		var pairs = CLEAN_PAIRS if is_clean else UNCLEAN_PAIRS
		return pairs * 2

@export var visual_color: Color = Color.WHITE
