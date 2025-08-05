extends Node

signal quarter_hour_event(float)

@export var start_time := 7.0

var game_minutes := 0
var real_seconds_per_game_minute := 60.0 / 60.0  # 1 real second = 1 game minute
var timer := Timer.new()

func _ready():
	game_minutes = start_time * 60
	timer.wait_time = real_seconds_per_game_minute
	timer.one_shot = false
	timer.timeout.connect(_on_tick)
	add_child(timer)
	timer.start()

func _on_tick():
	game_minutes += 1
	if game_minutes % 15 == 0:
		if(game_minutes >= 1440):
			game_minutes = 0
		emit_signal("quarter_hour_event", game_minutes/60.0)
