extends PathFollow2D


var speed = 0.0
var accel = 3.0
var min_drag = 0.3
var max_drag = 0.9

var max_turn = 30.0
var turn_speed = 2.0

var max_pitch = 2.5

onready var graphics = $Graphics
onready var track_time_display = $CanvasLayer/TrackTime
var track_time = 0.0
var best_track_time = -1.0
func _ready():
	$CanvasLayer/NewRecord.hide()
	set_physics_process(false)
	load_track_time()


func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("load_track_1"):
		get_tree().change_scene("res://tracks/Track1.tscn")
	if Input.is_action_just_pressed("load_track_2"):
		get_tree().change_scene("res://tracks/Track2.tscn")
	if Input.is_action_just_pressed("load_track_3"):
		get_tree().change_scene("res://tracks/Track3.tscn")
	if Input.is_action_just_pressed("load_track_4"):
		get_tree().change_scene("res://tracks/Track4.tscn")

func _physics_process(delta):
	track_time += delta
	track_time_display.text = "Track Time: " + str(stepify(track_time, 0.01))
	var last_r = graphics.global_rotation
	
	var t_s = graphics.rotation_degrees / max_turn
	var t = abs(t_s)
	
	var drag = lerp(min_drag, max_drag, t)
	
	speed += (accel - speed * drag) * delta
	
	var l_o = offset
	offset += speed
	if offset < l_o:
		stop_car()
		save_track_time()
	
	graphics.global_rotation = last_r
	var turn_amnt = Input.get_action_strength("turn_down") - Input.get_action_strength("turn_up")
	graphics.rotation_degrees += turn_amnt * turn_speed
	var cur_r = graphics.rotation_degrees
	if cur_r > 180:
		cur_r -= 360
	if cur_r < -180:
		cur_r += 360
	
	graphics.rotation_degrees = clamp(cur_r, -max_turn, max_turn)
	if t_s >= 0.0:
		Input.start_joy_vibration(0, 0.0, t, 0.0)
	else:
		Input.start_joy_vibration(0, t, 0.0, 0.0)
	
	$EngineSound.pitch_scale = lerp(max_pitch, 1.0, t)

func start_car():
	$EngineSound.play()
	set_physics_process(true)

func stop_car():
	$EngineSound.stop()
	set_physics_process(false)

func vibrate_all():
	Input.start_joy_vibration(0, 1.0, 0.0, 0.0)

func stop_vibrate():
	Input.stop_joy_vibration(0)

var save_data = {}
const SAVE_FILE_NAME = "RACE_TIMES.save"
func save_track_time():
	if track_time > best_track_time and best_track_time >= 0.0:
		$AnimationPlayer.play("completed_race")
		return
	$AnimationPlayer.play("completed_race_new_record")
	
	$CanvasLayer/NewRecord.show()
	var file = File.new()
	file.open(SAVE_FILE_NAME, File.WRITE)
	save_data[get_level_id()] = track_time
	file.store_string(to_json(save_data))
	file.close()

func load_track_time():
	var file = File.new()
	if !file.file_exists(SAVE_FILE_NAME):
		$CanvasLayer/BestTrackTime.hide()
		return
	
	file.open(SAVE_FILE_NAME, File.READ)
	save_data = parse_json(file.get_as_text())
	file.close()
	
	if get_level_id() in save_data:
		best_track_time = save_data[get_level_id()]
		$CanvasLayer/BestTrackTime.text = "Best Time: " + str(stepify(best_track_time, 0.01))
	else:
		$CanvasLayer/BestTrackTime.hide()

func get_level_id():
	return get_tree().get_current_scene().get_name()
