extends Node

# 音频管理器 - 处理游戏音效和背景音乐
# 注意：需要实际的音频文件 (.ogg, .wav) 才能播放

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# 音量控制
var music_volume: float = 0.0
var sfx_volume: float = 0.0

# 背景音乐
var current_music: String = ""

signal music_changed(track_name: String)
signal sfx_played(sfx_name: String)

func _ready():
	_setup_audio_players()
	_connect_signals()

func _setup_audio_players():
	# 背景音乐播放器
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	music_player.volume_db = -10.0  # 默认音量
	music_player.autoplay = false
	add_child(music_player)
	
	# 音效播放器
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	sfx_player.bus = "SFX"
	sfx_player.volume_db = -5.0
	sfx_player.autoplay = false
	add_child(sfx_player)

func _connect_signals():
	# 连接阶段变化信号
	var pm = get_node_or_null("/root/PhaseManager")
	if pm:
		pm.phase_changed.connect(_on_phase_changed)
	
	# 连接生存事件信号
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.survival_event.connect(_on_survival_event)

# 播放背景音乐
func play_music(track_name: String):
	current_music = track_name
	music_changed.emit(track_name)
	print("🎵 播放音乐: ", track_name)
	# 实际播放需要加载音频文件：
	# var stream = load("res://audio/music/" + track_name + ".ogg")
	# music_player.stream = stream
	# music_player.play()

# 停止音乐
func stop_music():
	music_player.stop()
	current_music = ""
	print("⏹️ 停止音乐")

# 暂停音乐
func pause_music():
	music_player.stream_paused = true

# 恢复音乐
func resume_music():
	music_player.stream_paused = false

# 播放音效
func play_sfx(sfx_name: String):
	sfx_played.emit(sfx_name)
	print("🔊 播放音效: ", sfx_name)
	# 实际播放需要加载音频文件：
	# var stream = load("res://audio/sfx/" + sfx_name + ".wav")
	# sfx_player.stream = stream
	# sfx_player.play()

# 设置音乐音量
func set_music_volume(db: float):
	music_volume = db
	music_player.volume_db = db

# 设置音效音量
func set_sfx_volume(db: float):
	sfx_volume = db
	sfx_player.volume_db = db

# ===== 阶段相关音乐 =====

func _on_phase_changed(from, to):
	match to:
		0:  # PREPARATION
			play_music("preparation")
		1:  # DELUGE
			play_music("deluge")
		2:  # DRIFT
			play_music("drift")

# ===== 事件相关音效 =====

func _on_survival_event(message: String):
	# 根据消息类型播放不同音效
	if "💀" in message or "死亡" in message:
		play_sfx("death")
	elif "饥饿" in message or "食物" in message:
		play_sfx("hunger")
	elif "水" in message:
		play_sfx("thirst")
	elif "🐣" in message or "繁殖" in message:
		play_sfx("birth")
	elif "瘟疫" in message:
		play_sfx("plague")
	elif "暴风雨" in message or "⛈️" in message:
		play_sfx("storm")
	elif "洪水" in message or "🌊" in message:
		play_sfx("flood")
	elif "🎉" in message or "胜利" in message:
		play_sfx("victory")

# ===== 预设音效列表 =====
# 需要添加实际的音频文件到 res://audio/sfx/ 目录

const SFX_LIST = {
	"click": "点击按钮",
	"place": "放置物品",
	"remove": "移除物品",
	"feed": "喂食",
	"death": "死亡",
	"birth": "出生",
	"hunger": "饥饿",
	"thirst": "口渴",
	"plague": "瘟疫",
	"storm": "暴风雨",
	"flood": "洪水",
	"victory": "胜利",
	"defeat": "失败",
	"task_complete": "任务完成",
	"task_new": "新任务"
}

const MUSIC_LIST = {
	"preparation": "准备阶段 - 平静的主题曲",
	"deluge": "大洪水 - 紧张的暴风雨配乐",
	"drift": "漂流阶段 - 孤独而充满希望的旋律"
}

func get_available_sfx() -> Array:
	return SFX_LIST.keys()

func get_available_music() -> Array:
	return MUSIC_LIST.keys()
