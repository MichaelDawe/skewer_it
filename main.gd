extends Node3D

var mode = 0 # 0 = menu, 1 = gameplay, 2 = paused, ...
var quit = false # used to indicate that the script should delete all 3D elements if the player has quit
var difficulty = 1 # 0 = easy / slow, 1 = normal, 2 = hard / fast
var shouldSpawn = 0.0 # when over x will spawn new item
var speedBoost = 1.0 # speeeeeeeeds the game up over time

# Called when the node enters the scene tree for the first time.
func _ready():
	# read difficutly from file
	if FileAccess.file_exists("user://difficulty.res"):
		var file = FileAccess.open("user://difficulty.res", FileAccess.READ)
		difficulty = file.get_8()
		file.close()
	# open menu scene
	var menu = preload("res://menu.tscn").instantiate()
	add_child(menu)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	shouldSpawn = shouldSpawn + 1.0 * delta * speedBoost
	if shouldSpawn > 10:
		shouldSpawn = 0
		# spawn stuff
	
	# process pause signal
	if mode == 1:
		for n in $Vegies.get_children():
			if n.get_meta("spawned"):
				n.position.z += 0.1 * delta * speedBoost
				n.orientation.y += 0.1 * delta
			# process items
			
			# process score
