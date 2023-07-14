extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var main = get_node("/root/main")
	if(main.score > main.highscore):
		$VBoxContainer/Score.set_text("NEW HIGHSCORE: " + str(int(main.score)))
		$VBoxContainer/Highscore.set_text("PREVIOUS HIGHSCORE: " + str(int(main.highscore)))
		main.highscore = main.score
	else:
		$VBoxContainer/Score.set_text("SCORE: " + str(int(main.score)))
		$VBoxContainer/Highscore.set_text("HIGHSCORE: " + str(int(main.highscore)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_play_pressed():
	# load the hud scene
	var hud = preload("res://hud.tscn").instantiate()
	get_node("/root/main").add_child(hud)
	# set main scene into play mode
	get_node("/root/main").mode = 1
	# run the play script on the main scene
	get_node("/root/main").play()
	# kill the tutorial
	queue_free()


func _on_menu_pressed():
	var menu = preload("res://menu.tscn").instantiate()
	get_node("/root/main").add_child(menu)
	queue_free()
