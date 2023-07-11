extends Control

@onready var main = get_node("/root/main")

# Called when the node enters the scene tree for the first time.
func _ready():
	# display score in hud
	$MarginContainer/Score.set_text("SCORE: " + str(int(main.score)) + 
									" Bonus: " + str(main.bonus - 1))
	$MarginContainer/Health.set_text("Tries: " + str(main.health))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_pause_pressed():
	main.pause()
	# pause the main scene
	main.mode = 2
	# spawn pause menu
	var pause = preload("res://pause.tscn").instantiate()
	main.add_child.call_deferred(pause)
	# save highscore to file
	var highscore = 0
	if(FileAccess.file_exists("user://highscore.res")):
		var file = FileAccess.open("user://highscore.res", FileAccess.READ)
		highscore = file.get_32()
		file.close()
	if(main.score > highscore):
		var file = FileAccess.open("user://highscore.res", FileAccess.WRITE)
		file.store_32(main.score)
		file.close()
	# 
	queue_free()

func _notification(what):
	# detect if app switched and save highscore to file
	# seems to work on android to save the score when you go home, 
	# open another app, or even close the app
	if(what == MainLoop.NOTIFICATION_APPLICATION_PAUSED):
		if(main.mode == 1):
			_on_pause_pressed()

func update_hud():
	# display score in hud
	$MarginContainer/Score.set_text("SCORE: " + str(int(main.score)) + 
									" Bonus: " + str(main.bonus - 1))

	$MarginContainer/Health.set_text("Tries: " + str(main.health))

func show_highscore():
	$MarginContainer/Score.set_text("NEW HIGHSCORE!")
