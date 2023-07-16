extends Control

var speedint = 10
var speed = "error"
var audioTxt = "error"
var postEffects = 1
@onready var main = get_node("/root/main")

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/PostEffects.set_text("POST EFFECTS OFF")
	if(FileAccess.file_exists("user://posteffects.res")):
		var file = FileAccess.open("user://posteffects.res", FileAccess.READ)
		postEffects = file.get_8()
		file.close()
	if(postEffects == 1):
		$VBoxContainer/PostEffects.set_text("POST EFFECTS ON")
	
	# change text in speed button
	speedint = main.speed
	if(speedint == 10): speed = "NORMAL"
	elif(speedint == 5): speed = "HALF" 
	elif(speedint == 20): speed = "DOUBLE"
	$VBoxContainer/Difficulty.set_text("SPEED: " + speed)
	
	# change text in audio button
	if(main.audio == 0): audioTxt = "AUDIO: OFF" 
	elif(main.audio == 1): audioTxt = "AUDIO: FX ONLY"
	elif(main.audio == 2): audioTxt = "AUDIO: ON"
	$VBoxContainer/Audio.set_text(audioTxt)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_credits_pressed():
	var credits = preload("res://credits.tscn").instantiate()
	main.add_child(credits)
	queue_free()


func _on_back_pressed():
	var menu = preload("res://menu.tscn").instantiate()
	main.add_child(menu)
	queue_free()


func _on_reset_score_pressed():
	var file
	file = FileAccess.open("user://highscore.res", FileAccess.WRITE)
	file.store_32(0)
	file.close()
	$"VBoxContainer/Reset Score".set_text("HIGHSCORE RESET")
	var bestHighscore = 0
	if(FileAccess.file_exists("user://bestHigh.res")):
		file = FileAccess.open("user://bestHigh.res", FileAccess.READ)
		bestHighscore = file.get_32()
		file.close()
	if(main.highscore > bestHighscore):
		file = FileAccess.open("user://bestHigh.res", FileAccess.WRITE)
		file.store_32(main.highscore)
		file.close()

func _on_tutorial_pressed():
	var tutorial = preload("res://tutorial.tscn").instantiate()
	main.add_child(tutorial)
	queue_free()


func _on_difficulty_pressed():
	# set value
	speedint *= 2
	if(speedint == 40): speedint = 5
	# bad code - remove before publishing
	# sets the speed value to work with new system, was 0,1,2; now 5,10,20
	if(speedint != 5 and speedint != 10 and speedint != 20): speedint = 10
	main.speed = speedint
	# change text in button
	speed = "error"
	if(speedint == 5): speed = "HALF" 
	elif(speedint == 10): speed = "NORMAL"
	elif(speedint == 20): speed = "DOUBLE"
	$VBoxContainer/Difficulty.set_text("SPEED: " + speed) #  + " " + str(speedint)
	# save to file
	var file = FileAccess.open("user://speed.res", FileAccess.WRITE)
	file.store_8(speedint)
	file.close()


func _on_post_effects_pressed():
	var file = FileAccess.open("user://posteffects.res", FileAccess.WRITE)
	if(postEffects == 0):
		postEffects = 1
		$VBoxContainer/PostEffects.set_text("POST EFFECTS ON")
	else:
		postEffects = 0
		$VBoxContainer/PostEffects.set_text("POST EFFECTS OFF")
	file.store_8(postEffects)
	file.close()


func _on_audio_pressed():
	main.audio += 1
	if(main.audio == 3): main.audio = 0
	var file = FileAccess.open("user://audio.res", FileAccess.WRITE)
	file.store_8(main.audio)
	file.close()
	# change text in button
	if(main.audio == 0): audioTxt = "AUDIO: OFF" 
	elif(main.audio == 1): audioTxt = "AUDIO: FX ONLY"
	elif(main.audio == 2): audioTxt = "AUDIO: ON"
	$VBoxContainer/Audio.set_text(audioTxt)
	get_node("/root/main/Music").process_music_mode(main.audio)


func _on_stats_pressed():
	var stats = preload("res://Stats.tscn").instantiate()
	main.add_child(stats)
	queue_free()
