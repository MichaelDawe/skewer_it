extends Node3D

var mode = 0 # 0 = menu, 1 = gameplay, 2 = paused, ...
var speed = 10 # 5 = easy / slow, 10 = normal, 20 = hard / fast
var speedBoost = 1.0 # speeeeeeeeds the game up over time
var spawnNowQ = 5.5 # time, in seconds, since last spawn.
var spawnInterval = 2.0 # time, in seconds, for each item to spawn, at the startttt.
var score = 0.0 # score
var ratio = 0.0 # stuff to devide mouse input by.
var catch = 0.0 # catch animation shader uniform thingy
var damaged = 0.0 # damage animation shader uniform thingy
var highscore # highscore
var highscoreBeat # used to flash the screen when the highscore is beaten, or control music
var scoreText = "SCORE: "
var mouseX = 0.0
var mouseY = 0.0
var bonus = 1.0 # score multiplier
var caught = [0, 0, 0, 0, 0, 0] # list of objects already on skewer
								# there are 5 places, with index 0 used
								# for when the skewer is empty ahh
var health = 3.0# starting health (maybe modify it based on difficulty?)
				# probably default of 3 or 5, its 5 below but 2 here for debug
				# could replace with just the bonus actually, 
				# which resets when you make a mistake
var caughtPos = 0 # 0 = empty
var gameMode = 0 # 0 = normal, 1 = infinite mode (no highscore), 2 = ect.
var backgroundMain = Vector3(0.0, 0.2, 0.6)
var background = Vector3(0.0, 0.2, 0.6)
var backRed = 0.0
var playTime = 0.0
var finalSpeed = 1.0 	# combo of speedBoost and backRed for slow mo etc, 
						# precalculated once per frame and used where required

# Called when the node enters the scene tree for the first time.
func _ready():
	# get screen aspect ratio as a float e.g. 1.777... for a 16 / 9 display
	ratio = float(get_viewport().size.x) / float(get_viewport().size.y)
	# set shader background
	$MainCamera/Background.get_active_material(0).set_shader_parameter("background", background)
	# enable / dissable post effects
	if FileAccess.file_exists("user://posteffects.res"):
		var file = FileAccess.open("user://posteffects.res", FileAccess.READ)
		if(file.get_8() == 42):
			$MainCamera/PostProcess.visible = true
		file.close()
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
		reset_vegie(n)
		# pass ratio to shader
		n.get_child(0).get_active_material(0).set_shader_parameter("ratio", ratio)
		n.get_child(0).get_active_material(0).set_shader_parameter("background", background)
	# reset skewer to be hidden
	$Skewer.position = Vector3(0.0, 0.0, 128)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# assign finalSpeed
	finalSpeed = speedBoost / (1.0 + (backRed * 3)) # makes game slow to almost 1/3 speed at slowest point.
	
	# mouse positions
	mouseX = get_viewport().get_mouse_position().x + 1
	mouseY = get_viewport().get_mouse_position().y + 1
	
	# process pause signal
	if mode == 1:
		playTime += delta
		# run background shading
		backRed = clamp(((sin((playTime / 300) * PI)) - 0.9524) * 12.6, 0.0, 1.0)
		background = Vector3(backRed, 0.2, 0.6)
		$MainCamera/Background.get_active_material(0).set_shader_parameter("background", background)
		# spawning counter
		spawnNowQ += delta
		# process items
		for n in $Vegies.get_children():
			# set location in shader for pickup effects
			n.get_child(0).get_active_material(0).set_shader_parameter("pozition", n.position.z)
			n.get_child(0).get_active_material(0).set_shader_parameter("background", background)
			# process postion and rotation
			var rotationMeta = n.get_meta("rotation")
			if n.get_meta("spawned"):
				# update scale
				n.get_child(0).scale += Vector3(0.3, 0.3, 0.3) * delta * finalSpeed
				# this line gets rid of the "det == 0" error and gives a little margin for error
				n.scale = n.get_child(0).scale + Vector3(0.1, 0.1, 0.1)
				# update position
				n.position.z += 20 * delta * finalSpeed
				# apply rotation from saved random rotation direction
				n.rotate(Vector3(1, 0, 0), rotationMeta[0] * delta * finalSpeed)
				n.rotate(Vector3(0, 1, 0), rotationMeta[1] * delta * finalSpeed)
				n.rotate(Vector3(0, 0, 1), rotationMeta[2] * delta * finalSpeed)
				
				if n.position.z > 112: # send objects home ('kill' them)
					reset_vegie(n)
					
					
		# spawn new item
		if spawnNowQ > spawnInterval / finalSpeed:
			$Vegies.get_child(randi_range(0, 14)).set_meta("spawned", true)
			spawnNowQ = 0.0
		
		# render skewer
		$Skewer.position = Vector3(
			((mouseX / 1000) - (0.5 * ratio)) * 9.4,
			((0.0 - (mouseY / 1000)) + 0.5) * 9.4,
			55
		)
		$Skewer.look_at(Vector3(6, -6, 0), Vector3(0, 0, -1))
		
		# flash screen when highscore beaten
		if(int(score) > highscore and not highscoreBeat):
			catch += 2
			highscoreBeat = true
			scoreText = "NEW HIGHSCORE: "
			
	
	# process shader effects
	$MainCamera/PostProcess.get_active_material(0).set_shader_parameter("catch", catch)
	if(catch > 0.0): catch -= delta * 2
	else: catch = 0.0
	$MainCamera/PostProcess.get_active_material(0).set_shader_parameter("damaged", damaged)
	if(damaged > 0.0): damaged -= delta * 2
	else: damaged = 0.0
		
func pause():
	# set slo-mo to fade back in when the game resumes.
	pass

# func animate_skewer()

func update_skewer():
	for n in caughtPos:
		var child = $Skewer.get_child(caught[caughtPos] - 1)
		child.position.y = -85 + (caughtPos * 14)
		child.rotation = Vector3(0.0, randf(), 0.0)
	
func clear_skewer():
	for n in $Skewer.get_children():
		n.position.y = -1024

func quit_to_menu():
	# reset playtime to prevent starting in slow mode
	playTime = 0
	# reset everything.
	background = backgroundMain
	$MainCamera/Background.get_active_material(0).set_shader_parameter("background", background)
	# reset highscoreBeat
	highscoreBeat = false
	scoreText = "SCORE: "
	# set up items for first spawn
	for n in $Vegies.get_children():
		reset_vegie(n)
	# reset speed
	speedBoost = 1.0
	score = 0.0
	# reset skewer to be hidden
	$Skewer.position = Vector3(0.0, 0.0, 128)
	# more stuff copied from the top
	bonus = 1.0 # score multiplier
	caught = [0, 0, 0, 0, 0, 0] # list of objects already on skewer
								# there are 5 places, with index 0 used
								# for when the skewer is empty ahh
	health = 3 # starting health (maybe modify it based on difficulty?)
	caughtPos = 0 # 0 = empty
	# removed vegies from skewer
	update_skewer()
	clear_skewer()

func play():
	# fix playtime to start at 10 minutes till fade
	playTime = -300
	# silly workaround for scoring 0
	score = 0.5
	# enable / dissable post effects
	if FileAccess.file_exists("user://posteffects.res"):
		var file = FileAccess.open("user://posteffects.res", FileAccess.READ)
		if(file.get_8() == 42):
			$MainCamera/PostProcess.visible = true
		else:
			$MainCamera/PostProcess.visible = false
		file.close()
	# set highscore text when the game is first launched
	if(highscore == 0):
		scoreText = "NEW HIGHSCORE: "
	# because the scene is always loaded some things might need to be run when
	# re-entering the game after going to menu, and _ready() won't run then.
	speedBoost = speed / 10.0
	
func reset_vegie(n):
	# scale to 0
	n.get_child(0).scale = Vector3(0, 0, 0)
	n.scale = Vector3(0.1, 0.1, 0.1)
	# spawn in random location
	n.position.z = 0
	n.position.x = (randf() * 60) - 30
	n.position.y = (randf() * 60) - 30
	# assign random rotation 
	n.set_meta("rotation", Vector3(randf(), randf(), randf()))
	n.set_meta("spawned", false)

func score_add():
	score += 1 * bonus	# * (speed / 10.0)
						# overkill, but makes it harder on easy and easier on hard
	catch += 1
	# make game speed up over time
	speedBoost += 0.0025;	# make this a lot smaller thank 0.02 I think!
							# second half makes it exponentially harder for hard mode and easier for easy mode
							# to help prevent abusing the speed to increase your highscore
	update_skewer()

func save_highscore():
	var tempHighScore = 0
	if FileAccess.file_exists("user://highscore.res"):
		var file = FileAccess.open("user://highscore.res", FileAccess.READ)
		tempHighScore = file.get_32()
		file.close()
	if(score > tempHighScore):
		var file = FileAccess.open("user://highscore.res", FileAccess.WRITE)
		file.store_32(score)
		file.close()

func score_update(n):
	if(gameMode == 0):
		var number = n.get_meta("number")
		if(number not in caught):
			# updates caughtPos for next pick
			caughtPos += 1
			# loops and resets the skewer when full, make spawn sparks later
			if(caughtPos == 5):
				caughtPos = 0
				for i in 6:
					caught[i] = 0
				catch += 1
				bonus += 0.25 * (speed / 10.0)
				clear_skewer()
				# reset tries:
				if(health < 3.0): health += 0.25
			# updates latest pick
			if(caughtPos > 0):
				caught[caughtPos] = number
			score_add()
		else:
			# kill game / deduct health
			health -= 1
			damaged = 1
			bonus = 1.0
			# kill
			if(health <= 0):
				# write highscore
				save_highscore()
				# set mode
				mode = 0
				# add game over screen
				var game_over = preload("res://game_over.tscn").instantiate()
				add_child(game_over)
				# run the play script on the main scene
				quit_to_menu()
				get_node("hud").queue_free()
			# reset skewer
			for i in 6:
				caught[i] = 0
			# reset counter
			caughtPos = 0
			clear_skewer()

func _on_aubergine_input_event(_camera, _event, _position, _normal, _shape_idx):
	var n = $Vegies/Aubergine
	if(n.position.z > 64 and n.position.z < 96):
		reset_vegie(n)
		score_update(n)

func _on_garlic_input_event(_camera, _event, _position, _normal, _shape_idx):
	var n = $Vegies/Garlic
	if(n.position.z > 64 and n.position.z < 96):
		reset_vegie(n)
		score_update(n)

func _on_gerkin_input_event(_camera, _event, _position, _normal, _shape_idx):
	var n = $Vegies/Gerkin
	if(n.position.z > 64 and n.position.z < 96):
		reset_vegie(n)
		score_update(n)

func _on_yellow_pepper_input_event(_camera, _event, _position, _normal, _shape_idx):
	var n = $Vegies/YellowPepper
	if(n.position.z > 64 and n.position.z < 96):
		reset_vegie(n)
		score_update(n)

func _on_tomato_input_event(_camera, _event, _position, _normal, _shape_idx):
	var n = $Vegies/Tomato
	if(n.position.z > 64 and n.position.z < 96):
		reset_vegie(n)
		score_update(n)

func _on_tofu_input_event(_camera, _event, _position, _normal, _shape_idx):
	var n = $Vegies/Tofu
	if(n.position.z > 64 and n.position.z < 96):
		reset_vegie(n)
		score_update(n)

func _on_shallot_input_event(_camera, _event, _position, _normal, _shape_idx):
	var n = $Vegies/Shallot
	if(n.position.z > 64 and n.position.z < 96):
		reset_vegie(n)
		score_update(n)

func _on_sausage_input_event(_camera, _event, _position, _normal, _shape_idx):
	var n = $Vegies/Sausage
	if(n.position.z > 64 and n.position.z < 96):
		reset_vegie(n)
		score_update(n)

func _on_red_pepper_input_event(_camera, _event, _position, _normal, _shape_idx):
	var n = $Vegies/RedPepper
	if(n.position.z > 64 and n.position.z < 96):
		reset_vegie(n)
		score_update(n)

func _on_pineapple_input_event(_camera, _event, _position, _normal, _shape_idx):
	var n = $Vegies/Pineapple
	if(n.position.z > 64 and n.position.z < 96):
		reset_vegie(n)
		score_update(n)

func _on_olive_input_event(_camera, _event, _position, _normal, _shape_idx):
	var n = $Vegies/Olive
	if(n.position.z > 64 and n.position.z < 96):
		reset_vegie(n)
		score_update(n)

func _on_mushroom_input_event(_camera, _event, _position, _normal, _shape_idx):
	var n = $Vegies/Mushroom
	if(n.position.z > 64 and n.position.z < 96):
		reset_vegie(n)
		score_update(n)

func _on_marinated_tofu_input_event(_camera, _event, _position, _normal, _shape_idx):
	var n = $Vegies/MarinatedTofu
	if(n.position.z > 64 and n.position.z < 96):
		reset_vegie(n)
		score_update(n)

func _on_maize_input_event(_camera, _event, _position, _normal, _shape_idx):
	var n = $Vegies/Maize
	if(n.position.z > 64 and n.position.z < 96):
		reset_vegie(n)
		score_update(n)

func _on_green_pepper_input_event(_camera, _event, _position, _normal, _shape_idx):
	var n = $Vegies/GreenPepper
	if(n.position.z > 64 and n.position.z < 96):
		reset_vegie(n)
		score_update(n)

