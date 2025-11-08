@tool
extends PanelContainer

const POMODORO_CLOCK = preload("uid://cfxr2nbwski5")
const LEFT_EXPAND = preload("uid://ci7wvn2ag8orv")
const RIGHT_EXPAND = preload("uid://b5heotoqr71ws")

# TODO 倒计时面板 ===============>变 量<===============
#region 变量
var open_project_time_label: Label
var use_progress_bar: ProgressBar
var un_use_progress_bar: ProgressBar
var project_v_box_container: HBoxContainer
var hide_and_show_button: Button

var current_clock : PomodoroClock
var is_not_stop : bool = true

var h : int
var m : int
var s : int
var use_time : float
var open_time : float
var time : float = 86400:
	set(v):
		time = v
		var tween : Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_ignore_time_scale(false).set_parallel()
		tween.tween_property(self, "h", int(time / 3600), .5)
		tween.tween_property(self, "m", int(time / 60) % 60, .75)
		tween.tween_property(self, "s", int(time) - (int(time / 3600) * 3600 + int(time / 60) % 60 * 60), 1.)
#endregion

# TODO 倒计时面板 ===============>虚方法<===============
#region 常用的虚方法
func _ready() -> void:
	project_v_box_container = %ProjectVBoxContainer

	open_project_time_label = %OpenProjectTimeLabel
	use_progress_bar = %UseProgressBar
	un_use_progress_bar = %UnUseProgressBar
	hide_and_show_button = %HideAndShowButton

	if FileAccess.file_exists("res://addons/deers_time_plugin/time_save.tres"):
		var save : TimeSave = load("res://addons/deers_time_plugin/time_save.tres") as TimeSave
		time = save.time
		use_time = save.use_time
		open_time = save.open_time

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		is_not_stop = true
		%StopTimer.stop()
		%StopTimer.start()

func _physics_process(delta: float) -> void:
	open_time += delta
	if is_not_stop or not DisplayServer.window_is_focused():
		use_time += delta

func _exit_tree() -> void:
	var save : TimeSave = TimeSave.new()
	save.time = time
	save.use_time = use_time
	save.open_time = open_time
	ResourceSaver.save(save, "res://addons/deers_time_plugin/time_save.tres")
#endregion

# TODO 倒计时面板 ===============>信号链接方法<===============
#region 信号链接方法
func _on_stop_timer_timeout() -> void:
	is_not_stop = false

func _on_open_timer_timeout() -> void:
	open_project_time_label.text = "%s : %s : %s" % \
	[
		int(open_time / 3600),
		int(open_time / 60) % 60,
		int(open_time) - (int(open_time / 3600) * 3600 + int(open_time / 60) % 60 * 60)
	]
	project_v_box_container.tooltip_text = "有效项目时长：%s : %s : %s" % \
	[
		int(use_time / 3600),
		int(use_time / 60) % 60,
		int(use_time) - (int(use_time / 3600) * 3600 + int(use_time / 60) % 60 * 60)
	] + "\n" + "无效项目时长：%s : %s : %s" % \
	[
		int((open_time - use_time) / 3600),
		int((open_time - use_time) / 60) % 60,
		int((open_time - use_time)) - (int((open_time - use_time) / 3600) * 3600 + int((open_time - use_time) / 60) % 60 * 60)
	]
	use_progress_bar.max_value = open_time
	use_progress_bar.value = use_time
	un_use_progress_bar.max_value = open_time
	un_use_progress_bar.value = open_time - use_time

func _on_button_pressed() -> void:
	var tween : Tween
	if hide_and_show_button.icon == RIGHT_EXPAND:
		for i in project_v_box_container.get_children():
			if i is Label: continue
			if i is Button: continue
			if i is PomodoroClock: continue
			tween = create_tween()
			tween.tween_property(i, "modulate:a", 0, .1)
			await tween.finished
			i.hide()
		tween = create_tween()
		tween.tween_property(self, "custom_minimum_size:x", 0, .1)
		hide_and_show_button.icon = LEFT_EXPAND
	elif hide_and_show_button.icon == LEFT_EXPAND:
		tween = create_tween()
		tween.tween_property(self, "custom_minimum_size:x", 0, .1)
		await tween.finished
		for i in project_v_box_container.get_children():
			if i is Button: continue
			i.show()
			tween = create_tween()
			tween.tween_property(i, "modulate:a", 1, .1)
			await tween.finished
		hide_and_show_button.icon = RIGHT_EXPAND
#endregion


func _on_add_timer_button_pressed() -> void:
	if current_clock:
		current_clock.timer_cycle += 1
		return
	current_clock = POMODORO_CLOCK.instantiate()
	project_v_box_container.add_child(current_clock)
	current_clock._init_clock(25, 5)
