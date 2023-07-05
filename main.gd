extends Node3D

var mode = 0 # 0 = menu, 1 = gameplay, 2 = paused, ...
var speed = 1 # 0 = easy / slow, 1 = normal, 2 = hard / fast
var speedBoost = 1.0 # speeeeeeeeds the game up over time
var spawnNowQ = 5.5 # time, in seconds, since last spawn.
var spawnInterval = 2.0 # time, in seconds, for each item to spawn, at the startttt.
var score = 0.0 # score
var ratio = 0.0 # stuff to devide mouse input by.
var catch = 0.0 # catch animation shader uniform thingy
var highscore # highscore
var highscoreBeat # used to flash the screen when the highscore is beaten
var scoreText = "SCORE: "

# Called when the node enters the scene tree for the first time.
func _ready():
	# reset highscoreBeat
	highscoreBeat = false
	# read difficutly from file
	if FileAccess.file_exists("user://speed.res"):
		var file = FileAccess.open("user://speed.res", FileAccess.READ)
		speed = file.get_8()
		file.close()
	# open menu scene
	var menu = preload("res://menu.tscn").instantiate()
	add_child(menu)
	
	# set up items for first spawn
	for n in $Vegies.get_children():
		# scale to 0
		n.scale = Vector3(0, 0, 0)
		# spawn in random location
		n.position.z = 0
		n.position.x = (randf() * 60) - 30
		n.position.y = (randf() * 60) - 30
		# assign random rotation 
		n.set_meta("rotation", Vector3(randf(), randf(), randf()))
		n.set_meta("spawned", false)
	# reset skewer to be hidden
	$Skewer.position = Vector3(0.0, 0.0, 128)
	
	# setup mouse picqealkjngf
	ratio = float(get_viewport().size.x) / float(get_viewport().size.y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# process pause signal
	if mode == 1:
		# make game speed up over time
		speedBoost += 0.0001 * delta;
		# print(speedBoost)
		# spawning counter
		spawnNowQ += delta
		# process items
		for n in $Vegies.get_children():
			# set location in shader for pickup effects
			n.get_active_material(0).set_shader_parameter("pozition", n.position.z)
			# pass ratio to shader
			n.get_active_material(0).set_shader_parameter("ratio", ratio)
			# process postion and rotation
			var rotationMeta = n.get_meta("rotation")
			if n.get_meta("spawned"):
				# update scale
				n.scale += Vector3(0.3, 0.3, 0.3) * delta
				# update position
				n.position.z += 20 * delta * speedBoost
				# apply rotation from saved random rotation direction
				n.rotate(Vector3(1, 0, 0), rotationMeta[0] * delta)
				n.rotate(Vector3(0, 1, 0), rotationMeta[1] * delta)
				n.rotate(Vector3(0, 0, 1), rotationMeta[2] * delta)
				
				# send objects home ('kill' them)
				if n.position.z > 118:
					# scale to 0
					n.scale = Vector3(0, 0, 0)
					# re-spawn in random location
					n.position.z = 0
					n.position.x = (randf() * 60) - 30
					n.position.y = (randf() * 60) - 30
					# assign random rotation 
					n.set_meta("rotation", Vector3(randf(), randf(), randf()))
					# un-spawn, make inactive
					n.set_meta("spawned", false)
					
					
		# spawn new item
		if spawnNowQ > spawnInterval / speedBoost:
			$Vegies.get_child(randi_range(0, 14)).set_meta("spawned", true)
			spawnNowQ = 0.0
		
		# render skewer
		$Skewer.position = Vector3(
			((float(get_viewport().get_mouse_position().x) / 1000) - (0.5 * ratio)) * 9.4,
			((0.0 - (float(get_viewport().get_mouse_position().y) / 1000)) + 0.5) * 9.4,
			55
		)
		$Skewer.look_at(Vector3(6, -6, 0), Vector3(0, 0, -1))
		# render test position on hit plane
		#$teste.position = Vector3(
		#	((float(get_viewport().get_mouse_position().x) / 1000) * 68.0) - (34.0 * ratio),
		#	((-float(get_viewport().get_mouse_position().y) / 1000) * 68.0) + 34.0,
		#	0
		#)
		
		# process score
		# I'll just add delta to it here for now.
		score += delta
		
		# flash screen when highscore beaten
		if(int(score) > highscore and not highscoreBeat):
			catch = 1
			highscoreBeat = true
			scoreText = "NEW HIGHSCORE: "
			# highscoreMusic = true
			
	
	# process shader effects
	$MainCamera/PostProcess.get_active_material(0).set_shader_parameter("catch", catch)
	catch -= delta * 2
	if(catch < 0.0): catch = 0.0
		
func pause():
	# set slo-mo to fade back in when the game resumes.
	pass

func quit_to_menu():
	# reset everything.
	# reset highscoreBeat
	highscoreBeat = false
	scoreText = "SCORE: "
	# set up items for first spawn
	for n in $Vegies.get_children():
		# scale to 0
		n.scale = Vector3(0, 0, 0)
		# spawn in random location
		n.position.z = 0
		n.position.x = (randf() * 60) - 30
		n.position.y = (randf() * 60) - 30
		# assign random rotation 
		n.set_meta("rotation", Vector3(randf(), randf(), randf()))
		n.set_meta("spawned", false)
	# reset speed
	speedBoost = 1.0
	score = 0.0
	# reset skewer to be hidden
	$Skewer.position = Vector3(0.0, 0.0, 128)

func play():
	# aggggg
	if(highscore == 0):
		scoreText = "NEW HIGHSCORE: "
	# because the scene is always loaded some things might need to be run when
	# re-entering the game after going to menu, and _ready() won't run then.
	if(speed == 0): speedBoost = 0.5
	else: speedBoost = speed
