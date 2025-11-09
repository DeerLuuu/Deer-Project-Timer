@tool
class_name PomodoroClock extends PanelContainer

@onready var pomodoro_clock_timer: Timer = %PomodoroClockTimer
@onready var break_clock_timer: Timer = %BreakClockTimer
var pomodoro_time : float
var break_time : float
var timer_cycle : int = 1:
	set(v):
		timer_cycle = v
		if timer_cycle == 0:
			queue_free()
@onready var control: Control = $HBoxContainer/PanelContainer/Control
@onready var control_2: Control = $HBoxContainer/PanelContainer/Control2
@onready var label: Label = $HBoxContainer/Label

func _init_clock(_pomodoro_time : float, _break_time : float) -> void:
	pomodoro_time = _pomodoro_time
	break_time = _break_time
	pomodoro_clock_timer.start(pomodoro_time)

func _physics_process(_delta: float) -> void:
	tooltip_text = "剩余循环：%s\n当前状态：%s" % [
		timer_cycle,
		"工作" if break_clock_timer.is_stopped() else "休息",
		]

	label.text = "%ds" % pomodoro_clock_timer.time_left if break_clock_timer.is_stopped() else "%ds" % break_clock_timer.time_left

	if pomodoro_clock_timer.is_stopped():
		control.position = Vector2(0, 36 - 36 * (break_clock_timer.time_left / break_time) - 36)
		control_2.position = Vector2(0, 36 - 36 * (break_clock_timer.time_left / break_time))
	else :
		control.position = Vector2(0, 36 * (pomodoro_clock_timer.time_left / pomodoro_time) - 36)
		control_2.position = Vector2(0, 36 * (pomodoro_clock_timer.time_left / pomodoro_time))


func _on_pomodoro_clock_timer_timeout() -> void:
	timer_cycle -= 1
	break_clock_timer.start(break_time)

func _on_break_clock_timer_timeout() -> void:
	pomodoro_clock_timer.start(pomodoro_time)
