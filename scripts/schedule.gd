extends Resource

class_name  Schedule

var _tasks: Array[Task]

@export var normal_bias: Array[Room.RoomType]
@export var boardroom_bias: Array[Room.RoomType]
@export var kitchen_bias: Array[Room.RoomType]

const _interval := 0.25
var _room_type_names := {
	Room.RoomType.TOILET: "Bathroom break",
	Room.RoomType.BOARDROOM_A: "Meeting at boardroom A",
	Room.RoomType.BOARDROOM_B: "Meeting at boardroom B",
	Room.RoomType.BOSS_OFFICE: "Meeting with the Boss",
	Room.RoomType.DEFAULT: "Working",
	Room.RoomType.PARKING_LOT: "Parking Lot",
	Room.RoomType.KITCHEN: "Kitchen",
	Room.RoomType.OFFICE_A: "Meeting at office A",
	Room.RoomType.OFFICE_B: "Meeting at office B"
}

func _init() -> void:
	_tasks.append(_create_task(0, 8, Room.RoomType.PARKING_LOT))

	for i in range(1,37):
		var curr_time := (i + 31) * _interval
		var rand_room_type := Room.RoomType.DEFAULT
		if i < 9 || i > 12 && i < 17 || i > 20 && i < 25 || i > 30:
			rand_room_type = normal_bias.pick_random()
		if i > 16 && i < 21: #between 12 and 13
			rand_room_type = kitchen_bias.pick_random()
		if i > 8 && i < 13 || i > 24 && i < 31: #10 - 11 or 14 - 15.5
			rand_room_type = boardroom_bias.pick_random()
		_tasks.append(_create_task(curr_time, curr_time + _interval, rand_room_type))
	
	_tasks.append(_create_task(17, 24, Room.RoomType.PARKING_LOT))

func _create_task(start: float, end: float, location: Room.RoomType) -> Task:
	var task = Task.new()
	task.start_time = start
	task.end_time = end
	task.locationType = location
	task.label = _room_type_names[location]
	return task
	
func get_task(time: float) -> Task:
	var index = int(time/ _interval - 31)
	if index < 0 or index >= _tasks.size():
		return null
	return _tasks[index]

func print_schedule():
	for task in _tasks:
		print("%s → %s : %s" % [task.start_time, task.end_time, task.label])
