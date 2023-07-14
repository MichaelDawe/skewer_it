extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	# initialize everything
	var maxBonus = 0.0
	var gameTime = 0
	var totalScore = 0
	var longestGame = 0
	var totalPieces = 0
	var totalSkewers = 0
	var totalMistakes = 0
	# set everything
	if(FileAccess.file_exists("user://maxBonus.res")):
		var file = FileAccess.open("user://maxBonus.res", FileAccess.READ)
		maxBonus = file.get_float()
		file.close()
	if(FileAccess.file_exists("user://gameTime.res")):
		var file = FileAccess.open("user://gameTime.res", FileAccess.READ)
		gameTime = file.get_32()
		file.close()
	if(FileAccess.file_exists("user://totalScore.res")):
		var file = FileAccess.open("user://totalScore.res", FileAccess.READ)
		totalScore = file.get_32()
		file.close()
	if(FileAccess.file_exists("user://longestGame.res")):
		var file = FileAccess.open("user://longestGame.res", FileAccess.READ)
		longestGame = file.get_32()
		file.close()
	if(FileAccess.file_exists("user://totalPieces.res")):
		var file = FileAccess.open("user://totalPieces.res", FileAccess.READ)
		totalPieces = file.get_32()
		file.close()
	if(FileAccess.file_exists("user://totalSkewers.res")):
		var file = FileAccess.open("user://totalSkewers.res", FileAccess.READ)
		totalSkewers = file.get_32()
		file.close()
	if(FileAccess.file_exists("user://totalMistakes.res")):
		var file = FileAccess.open("user://totalMistakes.res", FileAccess.READ)
		totalMistakes = file.get_32()
		file.close()
	# assign everything
	$VBoxContainer/Stats.set_text("
TOTAL GAME TIME: [right]" + format_seconds(gameTime) + "[/right]
LONGEST GAME: [right]" + format_seconds(longestGame) + "[/right]
TOTAL SCORE: [right]" + str(totalScore) + "[/right]
TOTAL PIECES COLLECTED: [right]" + str(totalPieces) + "[/right]
TOTAL SKEWERS COMPLETED:        [right]" + str(totalSkewers) + "[/right]
TOTAL MISTAKES: [right]" + str(totalMistakes) + "[/right]
HIGHEST BONUS: [right]" + str(maxBonus) + "[/right]
BEST HIGHSCORE: [right]" + str(int(get_node("/root/main").highscore))
)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_menu_pressed():
	var menu = preload("res://menu.tscn").instantiate()
	get_node("/root/main").add_child(menu)
	queue_free()

func format_seconds(s):
	var seconds = s
	var minutes = 0
	var hours = 0

	while seconds > 60:
		minutes += 1
		seconds -= 60
	
	while minutes > 60:
		hours += 1
		minutes -= 60
	
	return str(hours) + "H " + str(minutes) + "M"
