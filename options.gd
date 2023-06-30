extends Control

var speedint = 3
var speed = "*"

# Called when the node enters the scene tree for the first time.
func _ready():
	speedint = get_node("/root/main").speed
	speed = "normal"
	if(speedint == 0): speed = "easy" 
	elif(speedint == 2): speed = "hard"
	$VBoxContainer/Difficulty.set_text("SPEED: " + speed)	


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
	file.close()


func _on_tutorial_pressed():
	var tutorial = preload("res://tutorial.tscn").instantiate()
	get_node("/root/main").add_child(tutorial)
	queue_free()


func _on_difficulty_pressed():
	# set value
	speedint += 1
	if(speedint == 3): speedint = 0
	get_node("/root/main").speed = speedint
	# change text in button
	speed = "normal"
	if(speedint == 0): speed = "easy" 
	elif(speedint == 2): speed = "hard"
	$VBoxContainer/Difficulty.set_text("SPEED: " + speed)	
	# save to file
	var file = FileAccess.open("user://speed.res", FileAccess.WRITE)
	file.store_8(speedint)
	file.close()
