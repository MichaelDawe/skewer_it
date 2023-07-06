extends Control

var speedint = 10
var speed = "error"
var postEffects = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/PostEffects.set_text("Post Effects Off")
	if FileAccess.file_exists("user://posteffects.res"):
		var file = FileAccess.open("user://posteffects.res", FileAccess.READ)
		postEffects = file.get_8()
		file.close()
	if(postEffects == 42):
		$VBoxContainer/PostEffects.set_text("Post Effects On")
	#
	speedint = get_node("/root/main").speed
	if(speedint == 10): speed = "normal"
	elif(speedint == 5): speed = "half" 
	elif(speedint == 20): speed = "double"
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
	$"VBoxContainer/Reset Score".set_text("Highscore reset")


func _on_tutorial_pressed():
	var tutorial = preload("res://tutorial.tscn").instantiate()
	get_node("/root/main").add_child(tutorial)
	queue_free()


func _on_difficulty_pressed():
	# set value
	speedint *= 2
	if(speedint == 40): speedint = 5
	# bad code - remove before publishing
	# sets the speed value to work with new system, was 0,1,2; now 5,10,20
	if(speedint != 5 and speedint != 10 and speedint != 20): speedint = 10
	get_node("/root/main").speed = speedint
	# change text in button
	speed = "error"
	if(speedint == 5): speed = "half" 
	elif(speedint == 10): speed = "normal"
	elif(speedint == 20): speed = "double"
	$VBoxContainer/Difficulty.set_text("SPEED: " + speed) #  + " " + str(speedint)
	# save to file
	var file = FileAccess.open("user://speed.res", FileAccess.WRITE)
	file.store_8(speedint)
	file.close()


func _on_post_effects_pressed():
	var file = FileAccess.open("user://posteffects.res", FileAccess.WRITE)
	if(postEffects == 0):
		postEffects = 42
		file.store_8(42)
		file.close()
		$VBoxContainer/PostEffects.set_text("Post Effects On")
	else:
		postEffects = 0
		file.store_8(0)
		file.close()
		$VBoxContainer/PostEffects.set_text("Post Effects Off")
