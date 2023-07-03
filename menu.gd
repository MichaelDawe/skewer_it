extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var highscore = ""
	if FileAccess.file_exists("user://highscore.res"):
		var file = FileAccess.open("user://highscore.res", FileAccess.READ)
		highscore = "highscore: " + str(file.get_32())
		file.close()
	$VBoxContainer/Highscore.set_text(highscore)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_play_pressed():
	# skip tutorial scene if its not the first run
	if FileAccess.file_exists("user://data.res"):
		# set main scene into play mode
		get_node("/root/main").mode = 1
		# load the hud scene
		var hud = preload("res://hud.tscn").instantiate()
		get_node("/root/main").add_child(hud)
	else:
		# load the tutorial scene
		var tutorial = preload("res://tutorial.tscn").instantiate()
		get_node("/root/main").add_child(tutorial)
	# run the play script on the main scene
	get_node("/root/main").play()
	# kill the menu scene
	queue_free()


func _on_options_pressed():
	var options = preload("res://options.tscn").instantiate()
	get_node("/root/main").add_child(options)
	queue_free()
