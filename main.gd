extends Node3D

var mode = 0 # 0 = menu, 1 = gameplay, 2 = paused, ...
var speed = 10 # 5 = easy / slow, 10 = normal, 20 = hard / fast
var speedBoost = 1.0 # speeeeeeeeds the game up over time
var spawnNowQ = 5.5 # time, in seconds, since last spawn.
var spawnInterval = 2.0 # time, in seconds, for each item to spawn, at the startttt.
var score = 0.0 # score
var ratio = 0.0 # stuff to devide mouse input by.
var catch = 0.0 # catch animation shader uniform thingy
var highscoreFlash = 0.0 # highscore animation shader uniform thingy
var sparks = 0.0 # grill animation shader uniform thingy
var damaged = 0.0 # damage animation shader uniform thingy
var highscore = 0.0 # highscore
var highscoreBeat = false # used to flash the screen when the highscore is beaten, or control music
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
var grillAnim = false
var grillAnimStop = false
var skewerMouseActive = true # stops the mouse control for the skewer while its being animated
var shaderTime = 0.0 # separate time for shader to seamlessly apply speed effects
var audio = 2 # 0 = mute, 1 = fx only, 2 = fx and music
var catchYourBreath = true
# stats
var totalGameTime = 0.0
var maxBonus = 0.0
var totalScore = 0
var longestGame = 0.0
var totalPieces = 0
var totalSkewers = 0
var totalMistakes = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# pass screen size to the post process shader
	$MainCamera/PostProcess.get_active_material(0).set_shader_parameter("screenSize", Vector2(get_viewport().size.x, get_viewport().size.y))
	# set audio mode.
	if(FileAccess.file_exists("user://audio.res")):
		var file = FileAccess.open("user://audio.res", FileAccess.READ)
		audio = file.get_8()
	# get screen aspect ratio as a float e.g. 1.777... for a 16 / 9 display
	ratio = float(get_viewport().size.x) / float(get_viewport().size.y)
	# set shader background
	$MainCamera/Background.get_active_material(0).set_shader_parameter("background", background)
	# enable / dissable post effects
	if(FileAccess.file_exists("user://posteffects.res")):
		var file = FileAccess.open("user://posteffects.res", FileAccess.READ)
		if(file.get_8() == 1):
			$MainCamera/PostProcess.visible = true
		file.close()
	else:
		var file = FileAccess.open("user://posteffects.res", FileAccess.WRITE)
		file.store_8(1)
		file.close()
		$MainCamera/PostProcess.visible = true
	# read difficutly from file
	if(FileAccess.file_exists("user://speed.res")):
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
	# assign speed for stars
	shaderTime += delta * 0.015 * finalSpeed
	$MainCamera/Background.get_active_material(0).set_shader_parameter("t", shaderTime)
	# mouse positions
	mouseX = get_viewport().get_mouse_position().x + 1
	mouseY = get_viewport().get_mouse_position().y + 1
	
	# process pause signal
	if(mode == 1):
		# stats
		totalGameTime += delta
		# text to explain the slow mo effect
		# potentially wasteful way to do it, running every frame
		if(backRed > 0.1):
			if(catchYourBreath):
				get_node("hud").catch_your_breath()
				catchYourBreath = false
		else: catchYourBreath = true
		#
		playTime += delta
		# run background shading 
		# 165*2 seconds = five minutes and 30 seconds
		# 5 minutes between slow mo sessions and 30 seconds of slow mo
		backRed = clamp((sin(((playTime - 165) / 165) * PI) - 0.9) * 8.0, 0.0, 0.6)
		background = Vector3(backRed, 0.2, 0.6 - (backRed / 2.0))
		$MainCamera/Background.get_active_material(0).set_shader_parameter("background", background)
		# spawning counter
		spawnNowQ += delta
		# process items
		for n in $Vegies.get_children():
			# set location in shader for pickup effects
			n.get_child(0).get_active_material(0).set_shader_parameter("pozition", n.position.z)
			n.get_child(0).get_active_material(0).set_shader_parameter("background", background)
			n.get_child(0).get_active_material(0).set_shader_parameter("t", shaderTime)
			# process postion and rotation
			var rotationMeta = n.get_meta("rotation")
			if(n.get_meta("spawned")):
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
				
				if(n.position.z > 104): # send objects home ('kill' them)
					reset_vegie(n)
		# process grill
		if(grillAnim):
			$Grill.position.z += 20 * delta * finalSpeed
			$Grill/Grill.scale += Vector3(0.3, 0.3, 0.3) * delta * finalSpeed
			$Grill/CollisionShape3D.scale = $Grill/Grill.scale + Vector3(0.1, 0.1, 0.1)
			$Grill.rotation = Vector3(0.1, 0.0, 0.0)
			if($Grill.position.z > 64):
				if(grillAnimStop):
					grillAnim = false
					grillAnimStop = false
				$Grill.position.z = 0
				$Grill/Grill.scale = Vector3(0.0, 0.0, 0.0)
				$Grill/CollisionShape3D.scale = Vector3(0.01, 0.01, 0.01)
					
		# spawn new item
		if(spawnNowQ > spawnInterval / finalSpeed):
			$Vegies.get_child(randi_range(0, 14)).set_meta("spawned", true)
			spawnNowQ = 0.0
		
		# render skewer
		if(skewerMouseActive):
			$Skewer.position = Vector3(
				((mouseX / 1000) - (0.5 * ratio)) * 9.4,
				((0.0 - (mouseY / 1000)) + 0.5) * 9.4,
				55
			)
			$Skewer.look_at(Vector3(6, -6, 0), Vector3(0, 0, -1))
		
			
	# process shader effects
	if($MainCamera/PostProcess.visible):
		$MainCamera/PostProcess.get_active_material(0).set_shader_parameter("catch", catch)
		if(catch > 0.0): catch -= delta * 2
		else: catch = 0.0
		$MainCamera/PostProcess.get_active_material(0).set_shader_parameter("damaged", damaged)
		if(damaged > 0.0): damaged -= delta * 2
		else: damaged = 0.0
		$MainCamera/PostProcess.get_active_material(0).set_shader_parameter("sparks", sparks)
		if(sparks > 0.0): sparks -= delta
		else: sparks = 0.0
		$MainCamera/PostProcess.get_active_material(0).set_shader_parameter("highscore", highscoreFlash)
		if(highscoreFlash > 0.0): highscoreFlash -= delta
		else: highscoreFlash = 0.0

func play_fx(fx):
	if(audio > 0):
		if(fx == 0):
			$BadFX.play()
		else:
			$GoodFX.pitch_scale = 0.8 + (fx / 5.0)
			$GoodFX.volume_db = fx
			$GoodFX.play()
			if(fx == 6):
				$GrillFX.play()

func update_skewer():
	for n in caughtPos:
		var child = $Skewer.get_child(caught[caughtPos] - 1)
		child.position.y = -80 + (caughtPos * 12)
		child.rotation = Vector3(0, randf(), 0)
	
func clear_skewer():
	for n in $Skewer.get_children():
		n.position.y = -1024

func save_stats():
	var file
	# total game time
	file = FileAccess.open("user://gameTime.res", FileAccess.WRITE)
	file.store_32(totalGameTime)
	file.close()
	# max bonus
	maxBonus = 0.0
	if(FileAccess.file_exists("user://maxBonus.res")):
		file = FileAccess.open("user://maxBonus.res", FileAccess.READ)
		maxBonus = file.get_float()
		file.close()
	if(bonus - 1.0 > maxBonus):
		file = FileAccess.open("user://maxBonus.res", FileAccess.WRITE)
		file.store_float(bonus - 1.0)
		file.close()
	# total score
	file = FileAccess.open("user://totalScore.res", FileAccess.WRITE)
	file.store_32(totalScore)
	file.close()
	# longest game
	if(FileAccess.file_exists("user://longestGame.res")):
		file = FileAccess.open("user://longestGame.res", FileAccess.READ)
		longestGame = file.get_32()
		file.close()
	if(playTime > longestGame):
		file = FileAccess.open("user://longestGame.res", FileAccess.WRITE)
		file.store_32(playTime)
		file.close()
	# total pieces
	file = FileAccess.open("user://totalPieces.res", FileAccess.WRITE)
	file.store_32(totalPieces)
	file.close()
	# total skewers
	file = FileAccess.open("user://totalSkewers.res", FileAccess.WRITE)
	file.store_32(totalSkewers)
	file.close()
	# total mistakes
	file = FileAccess.open("user://totalMistakes.res", FileAccess.WRITE)
	file.store_32(totalMistakes)
	file.close()

func pause():
	save_stats()

func quit_to_menu():
	grillAnim = false
	grillAnimStop = false
	$Grill.position.z = 0
	$Grill/Grill.scale = Vector3(0.0, 0.0, 0.0)
	$Grill/CollisionShape3D.scale = Vector3(0.01, 0.01, 0.01)
	# reset playtime to prevent starting in slow mode
	playTime = 0
	# reset everything.
	background = backgroundMain
	$MainCamera/Background.get_active_material(0).set_shader_parameter("background", background)
	# reset highscoreBeat
	highscoreBeat = false
	# set up items for first spawn
	for n in $Vegies.get_children():
		reset_vegie(n)
	# reset speed
	speedBoost = 1.0
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
	# make sure they're reset before the next game
	catch = 0
	damaged = 0
	sparks = 0

func play():
	# stats
	# total game time
	if(FileAccess.file_exists("user://gameTime.res")):
		var file = FileAccess.open("user://gameTime.res", FileAccess.READ)
		totalGameTime = file.get_32()
		file.close()
	# total score
	if(FileAccess.file_exists("user://totalScore.res")):
		var file = FileAccess.open("user://totalScore.res", FileAccess.READ)
		totalScore = file.get_32()
		file.close()
	# total pieces
	if(FileAccess.file_exists("user://totalPieces.res")):
		var file = FileAccess.open("user://totalPieces.res", FileAccess.READ)
		totalPieces = file.get_32()
		file.close()
	# total skewers
	if(FileAccess.file_exists("user://totalSkewers.res")):
		var file = FileAccess.open("user://totalSkewers.res", FileAccess.READ)
		totalSkewers = file.get_32()
		file.close()
	# total mistakes
	if(FileAccess.file_exists("user://totalMistakes.res")):
		var file = FileAccess.open("user://totalMistakes.res", FileAccess.READ)
		totalMistakes = file.get_32()
		file.close()
	# because the scene is always loaded some things might need to be run when
	# re-entering the game after going to menu, and _ready() won't run then.
	# silly workaround for scoring 0
	score = 0.5
	
	# setup music TODO
	## if(audio == 2): $Music.visible = true
	## else: $Music.visible = false
	
	# enable / dissable post effects
	if(FileAccess.file_exists("user://posteffects.res")):
		var file = FileAccess.open("user://posteffects.res", FileAccess.READ)
		if(file.get_8() == 1):
			$MainCamera/PostProcess.visible = true
		else:
			$MainCamera/PostProcess.visible = false
		file.close()
	speedBoost = speed / 10.0
	get_node("hud").update_hud()
	# check for first run after reset highscore
	if(highscore < 0.5): highscoreBeat = true
	
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
	score += 1 * bonus
	catch += 1
	# make game speed up over time
	speedBoost += 0.0015
	update_skewer()
	# stats
	totalScore += 1 * bonus
	totalPieces += 1

func save_highscore():
	var tempHighScore = 0
	if(FileAccess.file_exists("user://highscore.res")):
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
		# process score for the item caught
		if(number not in caught):
			# updates caughtPos for next pick
			caughtPos += 1
			# loops and resets the skewer when full, make spawn sparks later
			if(caughtPos > 5):
				wrong_piece()
				play_fx(0)
			else:
				if(caughtPos == 5):
					grillAnim = true
				# updates latest pick
				caught[caughtPos] = number
				score_add()
				play_fx(caughtPos)
		else:
			wrong_piece()
			play_fx(0)

func wrong_piece():
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
		pause()
		quit_to_menu()
		get_node("hud").queue_free()
	# reset skewer
	for i in 6:
		caught[i] = 0
	# reset counter
	caughtPos = 0
	clear_skewer()
	if(grillAnim): grillAnimStop = true
	# stats
	totalMistakes += 1

func process_input(n, event):
	# UNCOMMENT BEFORE PUBLISHING!
	if(event is InputEventMouse):
		var nZ = n.position.z
		if(nZ > 64 and nZ < 96):
			# make it a bit easier to catch items when you want to without affecting when you don't want them
			if(nZ > 90):
				if(n.get_meta("number") not in caught and caughtPos < 5):
					reset_vegie(n)
					score_update(n)
				else:
					pass # is this nessesary?
			else:
				reset_vegie(n)
				score_update(n)
			get_node("hud").update_hud()
			# flash screen when highscore beaten
			if(int(score) > highscore and not highscoreBeat):
				highscoreFlash += 1
				highscoreBeat = true
				get_node("hud").show_highscore()

func _on_aubergine_input_event(_camera, event, _position, _normal, _shape_idx):
	if(mode == 1):
		var n = $Vegies/Aubergine
		process_input(n, event)

func _on_garlic_input_event(_camera, event, _position, _normal, _shape_idx):
	if(mode == 1):
		var n = $Vegies/Garlic
		process_input(n, event)

func _on_gerkin_input_event(_camera, event, _position, _normal, _shape_idx):
	if(mode == 1):
		var n = $Vegies/Gerkin
		process_input(n, event)

func _on_yellow_pepper_input_event(_camera, event, _position, _normal, _shape_idx):
	if(mode == 1):
		var n = $Vegies/YellowPepper
		process_input(n, event)

func _on_tomato_input_event(_camera, event, _position, _normal, _shape_idx):
	if(mode == 1):
		var n = $Vegies/Tomato
		process_input(n, event)

func _on_tofu_input_event(_camera, event, _position, _normal, _shape_idx):
	if(mode == 1):
		var n = $Vegies/Tofu
		process_input(n, event)

func _on_shallot_input_event(_camera, event, _position, _normal, _shape_idx):
	if(mode == 1):
		var n = $Vegies/Shallot
		process_input(n, event)

func _on_sausage_input_event(_camera, event, _position, _normal, _shape_idx):
	if(mode == 1):
		var n = $Vegies/Sausage
		process_input(n, event)

func _on_red_pepper_input_event(_camera, event, _position, _normal, _shape_idx):
	if(mode == 1):
		var n = $Vegies/RedPepper
		process_input(n, event)

func _on_pineapple_input_event(_camera, event, _position, _normal, _shape_idx):
	if(mode == 1):
		var n = $Vegies/Pineapple
		process_input(n, event)

func _on_olive_input_event(_camera, event, _position, _normal, _shape_idx):
	if(mode == 1):
		var n = $Vegies/Olive
		process_input(n, event)

func _on_mushroom_input_event(_camera, event, _position, _normal, _shape_idx):
	if(mode == 1):
		var n = $Vegies/Mushroom
		process_input(n, event)

func _on_marinated_tofu_input_event(_camera, event, _position, _normal, _shape_idx):
	if(mode == 1):
		var n = $Vegies/MarinatedTofu
		process_input(n, event)

func _on_maize_input_event(_camera, event, _position, _normal, _shape_idx):
	if(mode == 1):
		var n = $Vegies/Maize
		process_input(n, event)

func _on_green_pepper_input_event(_camera, event, _position, _normal, _shape_idx):
	if(mode == 1):
		var n = $Vegies/GreenPepper
		process_input(n, event)

func _on_grill_input_event(_camera, _event, _position, _normal, _shape_idx):
	if(mode == 1 and caughtPos == 5 and $Grill.position.z > 32):
		# stop grill after animation cycle
		grillAnimStop = true
		# clear skewer etc.
		caughtPos = 0
		for i in 6:
			caught[i] = 0
		#catch += 2 # may be temporary until sparks are in place, then drop to 1 or remove
		sparks += 1
		bonus += 0.25 * (speed / 10.0)
		clear_skewer()
		# reset tries:
		if(health < 3.0): health += 0.25
		play_fx(6)
		get_node("hud").update_hud()
		# stats
		totalSkewers += 1
