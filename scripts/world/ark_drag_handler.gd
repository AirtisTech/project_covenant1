extends Control

func _can_drop_data(at_position, data):
	if data is Dictionary and data.get("type") == "animal_species":
		var species = data.get("species")
		var ark = get_parent()
		if ark:
			ark.call("update_placement_preview", at_position, species)
		return true
	return false

func _drop_data(at_position, data):
	var species = data.get("species")
	if species:
		var ark = get_parent()
		if ark:
			# 暴力测试：直接放置，不经过 try_place 的层层校验
			# 只要在感应区内放下，就在该点最近的甲板建一个
			ark.call("try_place_at_world_pos", at_position, species)