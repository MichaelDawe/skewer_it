extends Control

var main

# Called when the node enters the scene tree for the first time.
func _ready():
	# set main
	main = get_node("/root/main")
	# highscore
	if(FileAccess.file_exists("user://highscore.res")):
		var file = FileAccess.open("user://highscore.res", FileAccess.READ)
		main.highscore = file.get_32()
		file.close()
		$VBoxContainer/Highscore.set_text("highscore: " + str(main.highscore))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_play_pressed():
	# skip tutorial scene if its not the first run
	if(FileAccess.file_exists("user://firstopen.res")):
		# set main scene into play mode
		main.mode = 1
		# load the hud scene
		var hud = preload("res://hud.tscn").instantiate()
		main.add_child(hud)
		# run the play script on the main scene
		main.play()
	else:
		# load the tutorial scene
		var tutorial = preload("res://tutorial.tscn").instantiate()
		main.add_child(tutorial)
	# kill the menu scene
	queue_free()


func _on_options_pressed():
	var options = preload("res://options.tscn").instantiate()
	main.add_child(options)
	queue_free()


func _on_quit_pressed():
	get_tree().quit()
