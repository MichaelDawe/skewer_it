extends Control

var diffint = 3
var difficulty = "*"

# Called when the node enters the scene tree for the first time.
func _ready():
	diffint = get_node("/root/main").difficulty
	difficulty = "normal"
	if(diffint == 0): difficulty = "easy" 
	elif(diffint == 2): difficulty = "hard"
	$VBoxContainer/Difficulty.set_text("DIFFICULTY: " + difficulty)	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_credits_pressed():
	var credits = preload("res://credits.tscn").instantiate()
	get_node("/root/main").add_child(credits)
	queue_free()


func _on_back_pressed():
	var menu = preload("res://menu.tscn").instantiate()
	get_node("/root/main").add_child(menu)
	queue_free()


func _on_reset_score_pressed():
	var file = FileAccess.open("user://highscore.res", FileAccess.WRITE)
	file.store_32(0)
	file.close


func _on_tutorial_pressed():
	var tutorial = preload("res://tutorial.tscn").instantiate()
	get_node("/root/main").add_child(tutorial)
	queue_free()


func _on_difficulty_pressed():
	# set value
	diffint += 1
	if(diffint == 3): diffint = 0
	get_node("/root/main").difficulty = diffint
	# change text in button
	difficulty = "normal"
	if(diffint == 0): difficulty = "easy" 
	elif(diffint == 2): difficulty = "hard"
	$VBoxContainer/Difficulty.set_text("DIFFICULTY: " + difficulty)	
	# save to file
	var file = FileAccess.open("user://difficulty.res", FileAccess.WRITE)
	file.store_8(diffint)
	file.close
