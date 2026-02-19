extends Node

# 为不同场景定义震动时长 (单位：毫秒)
const LIGHT = 20
const MEDIUM = 80
const HEAVY = 200

func play_vibrate(duration: int = LIGHT):
	# 只有在移动端才会生效
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(duration)
	else:
		# PC 端的调试提示
		# print("[Haptic] 触发震动反馈: ", duration, "ms")
		pass

func light(): play_vibrate(LIGHT)
func medium(): play_vibrate(MEDIUM)
func heavy(): play_vibrate(HEAVY)
