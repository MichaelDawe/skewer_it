extends Control

var main

# Called when the node enters the scene tree for the first time.
func _ready():
	main = get_node("/root/main")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# score should be processed in main scene and written here, but for testing
	# I'll just add delta to it here.
	main.score += delta
	# display score in hud
	$MarginContainer/Score.set_text("SCORE: " + str(int(main.score)))
	# detect if window loses focus and save highscore to file


func _on_pause_pressed():
	# pause the main scene
	main.mode = 2
	# spawn pause menu
	var pause = preload("res://pause.tscn").instantiate()
	main.add_child(pause)
	# save highscore to file
	var highscore = 0
	if FileAccess.file_exists("user://highscore.res"):
		var file = FileAccess.open("user://highscore.res", FileAccess.READ)
		highscore = file.get_32()
		file.close()
	if(main.score > highscore):
		var file = FileAccess.open("user://highscore.res", FileAccess.WRITE)
		file.store_32(main.score)
		file.close()
	# suic!de
	queue_free()
