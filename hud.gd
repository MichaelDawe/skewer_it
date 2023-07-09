extends Control

var main

# Called when the node enters the scene tree for the first time.
func _ready():
	main = get_node("/root/main")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# display score in hud
	# not ideal setting this every frame, want to make it callable from main
	$MarginContainer/Score.set_text(
							main.scoreText 
							+ str(int(main.score))
							+ " Bonus: " 
							+ str(main.bonus - 1))
	$MarginContainer/Health.set_text("Tries: " + str(main.health))

func _on_pause_pressed():
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
	# suic!de
	queue_free()

func _notification(what):
	# detect if window loses focus and save highscore to file
	# seems to work on android to save the score when you go home, 
	# open another app, or even close the app
	if(what == MainLoop.NOTIFICATION_APPLICATION_PAUSED):
		if(main.mode == 1):
			_on_pause_pressed()
