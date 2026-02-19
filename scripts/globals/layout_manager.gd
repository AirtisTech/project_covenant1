extends Node

var species_list: Array[AnimalSpecies] = []

signal species_status_changed(species: AnimalSpecies, is_placed: bool)

func _ready():
	_init_list()

func set_species_placed(species: AnimalSpecies, status: bool):
	species.is_placed = status
	species_status_changed.emit(species, status)

func _init_list():
	var sheep = AnimalSpecies.new()
	sheep.species_name = "Sheep (Clean)"
	sheep.description = "温顺物种。安顿它们非常容易。"
	sheep.is_clean = true
	sheep.base_width_cubits = 2.0
	sheep.base_weight = 1.0
	sheep.placement_faith_cost = 0.5 
	sheep.visual_color = Color.FLORAL_WHITE
	species_list.append(sheep)
	
	var cow = AnimalSpecies.new()
	cow.species_name = "Cow (Clean)"
	cow.description = "庞大的族群。搬运和安顿需要一定的毅力。"
	cow.is_clean = true
	cow.base_width_cubits = 4.0
	cow.base_weight = 4.0
	cow.placement_faith_cost = 1.5 
	cow.visual_color = Color.TAN
	species_list.append(cow)
	
	var lion = AnimalSpecies.new()
	lion.species_name = "Lion"
	lion.description = "猛兽。安顿狮子需要面对极大的恐惧。"
	lion.is_clean = false
	lion.diet = AnimalSpecies.Diet.CARNIVORE
	lion.base_width_cubits = 6.0
	lion.base_weight = 3.0
	lion.placement_faith_cost = 3.0 
	lion.visual_color = Color.GOLDENROD
	species_list.append(lion)
	
	var elephant = AnimalSpecies.new()
	elephant.species_name = "Elephant"
	elephant.description = "巨型物种。将其吊装进方舟底层是一场信念的磨炼。"
	elephant.is_clean = false
	elephant.base_width_cubits = 15.0
	elephant.base_weight = 15.0
	elephant.placement_faith_cost = 5.0 
	elephant.visual_color = Color.SLATE_GRAY
	species_list.append(elephant)