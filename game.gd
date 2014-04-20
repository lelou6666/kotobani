#    Kotobani - a game in which you create words to increase your points
#    Copyright (C) 2014  sammy fischer (sammy@cosmic-bandito.com)
#
#    This program is free software: you can redistribute it and/or modify                                                                
#    it under the terms of the GNU General Public License as published by                                                                
#    the Free Software Foundation, either version 3 of the License, or                                                                   
#    (at your option) any later version.                                                                                                 
#                                                                                                                                        
#    This program is distributed in the hope that it will be useful,                                                                     
#    but WITHOUT ANY WARRANTY; without even the implied warranty of                                                                      
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                                                                       
#    GNU General Public License for more details.                                                                                        
#                                                                                                                                        
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

extends Node2D

const _VERSION = "beta_2"
const _COPYRIGHT = "\ncopyright 2014 Sammy Fischer\n(sammy@cosmic-bandito.com)\nLicensed under GPLv3"

const _startX = 224
const _startY = 0
const _sizeX = 16
const _sizeY = 12
const _tileSize = 50
const _halfTileSize = 25
const _HIGHEST = 999999

const _localeCount = 3
const locale = ["en_US","de_DE","fr_FR"]

var currentLocale = 0
var initialTimer = [[60*2,30],[60,15],[-1,-1]]

var PLAY = false
var grid = []
var stars = []
var literalBool = {false:"false",true:"true"}

var tile = preload("res://tile.scn")
var starsPrtcl = preload("res://particles_rainbow.scn")

var scoreNode = null
var sfxNode = null
var lgWdNode = null
var crtWdNode = null
var lstWdNode = null
var progressionBar = null

var keyPressed = false

var soundToggle = 1
var musicToggle = 1
var doNotRestartMusic = false

var gameTimer = null
var timer = initialTimer[0][0]
var lastTimer = timer
var timerNode = null

var selectedTiles = []
var lastTile = [-1,-1]
var createdWord = ""
var selectedTileCnt = 0
var score = 0
var longestWord = ""
var level = 1
var nextLevelAt = 200
var oldLevelAt = 0

var gameMode = 0
var gameDifficulty = 0
var highScore = [[0,0],[0,0],[0,0]]

var lowestOrderedPerX = []

var options = null

var stats = null
var refs = null

func setScene(scene):
	get_node("titlescreen").hide()
	get_node("gameover").hide()
	get_node("options").hide()
	get_node("pause").hide()
	get_node("help").hide()
	if scene != "game":
		get_node(scene).show()
		get_node(scene).raise()
	

func storeOptions():
	var fh = File.new()
	fh.open("options.gd", File.WRITE)
	fh.store_line("var locale=\""+options.locale+"\"")
	fh.store_line("var localeIdx="+str(currentLocale)+"")
	fh.store_line("var highScore = [["+str(highScore[0][0])+","+str(highScore[0][1])+"],["+str(highScore[1][0])+","+str(highScore[1][1])+"],["+str(highScore[2][0])+","+str(highScore[2][1])+"]]")
	fh.store_line("var music="+str(musicToggle))
	fh.store_line("var sfx="+str(soundToggle))
	fh.store_line("var gameMode="+str(gameMode))
	fh.store_line("var gameDifficulty="+str(gameDifficulty))
	fh.close()

func resetKeyPressed():
	keyPressed = false
	
func preventKeyRepeat():
	keyPressed = true
	get_node("keyTimer").start()
		
func _input(e):
	if e.is_action("clear_selected"):
		if PLAY != true:
			return
		preventKeyRepeat()
		createdWord = ""
		lastTile = [-1,-1]
		clearSelected()
		selectedTileCnt = 0		
		return
	if e.is_action("music"):
		preventKeyRepeat()
		toggleMusic()
	if e.is_action("sound"):
		preventKeyRepeat()
		toggleSound()
	elif e.is_action("escape"):
		preventKeyRepeat()
		if PLAY == true:
			PLAY = false
			gameTimer.stop()
			freeGrid()
			if gameMode == 2:
				PLAY = true
				gameOver()
			else:
				titleMenu()
	elif e.is_action("pause"):
		preventKeyRepeat()
		if PLAY == true:
			pause()
		
func rebuildGrid():
	if PLAY != true:
		return
	for i in range(_sizeX*_sizeY):
		selectedTiles[i] = [-1,-1,null]
	for i in range(_sizeY):
		for s in range (_sizeX):
			grid[(i*_sizeX+s)].set_text(chooseRune())
			stars[i*_sizeX+s].set_emitting(true)

func pause():
	PLAY = false
	gameTimer.stop()
	setScene("pause")	

func unpause():
	PLAY = true
	if gameMode != 2:
		gameTimer.start()
	setScene("game")
	
func options():
	doNotRestartMusic = true
	setScene("options")

func freeGrid():
	for i in range(_sizeX*_sizeY):
		grid[i].remove_and_skip()
		stars[i].remove_and_skip()

func fireworks(on):
	for i in range(1,9):
		var nodename = "gameover/f"+str(i)
		get_node(nodename).set_emitting(on)

func gameOver():
	if PLAY != true:
		return
	get_node("gameover/gotHighscore").hide()	
	gameTimer.stop()
	PLAY = false
	freeGrid()
	setScene("gameover")
	if musicToggle:
		get_node("streamTitle").stop()
		get_node("streamGameOn").stop()
		get_node("streamGameOver").play()
	get_node("gameover/continue").connect("pressed",self,"titleMenu")
	get_node("gameover/finalScore").set_text(str(score))
	get_node("gameover/highScore").set_text(str(highScore[gameMode][gameDifficulty]))
	get_node("gameover/longWord").set_text(longestWord)
	if score > highScore[gameMode][gameDifficulty]:
		highScore[gameMode][gameDifficulty] = score	
		get_node("gameover/gotHighscore").show()
		fireworks(true)
	storeOptions()			

func help():
	if PLAY == true:
		return
	doNotRestartMusic = true
	setScene("help")
	
func _time_out():
	if PLAY != true:
		return
	timer = timer - 1
	var seconds = int(timer) % 60
	var minutes = int(floor(timer/60))
	timerNode.set_text(str(minutes)+":"+str(seconds).pad_zeros(2))
	if timer < 0:
		gameTimer.stop()
		gameOver()
	
func getOut():
	self.remove_and_skip()

func setTranslations():
	print(options.locale)
	stats = load("res://dicts/"+options.locale+"/stats.gd").new()
	refs = load("res://dicts/"+options.locale+"/references.gd").new()
	get_node("lastword-label").set_text(TranslationServer.translate("LASTWORD"))
	get_node("buffer-label").set_text(TranslationServer.translate("BUFFER"))
	get_node("longest-label").set_text(TranslationServer.translate("LONGWORD"))
	get_node("score-label").set_text(TranslationServer.translate("SCORE"))
	get_node("level-label").set_text(TranslationServer.translate("LEVEL"))

	if musicToggle:
		get_node("options/grid/musicBtn").set_text(TranslationServer.translate("MUSICON"))
	else:
		get_node("options/grid/musicBtn").set_text(TranslationServer.translate("MUSICOFF"))
	if soundToggle:
		get_node("options/grid/soundBtn").set_text(TranslationServer.translate("SOUNDON"))
	else:
		get_node("options/grid/soundBtn").set_text(TranslationServer.translate("SOUNDOFF"))	
		
	var modeLabel = "MODE"+str(gameMode)
	get_node("options/grid/modeBtn").set_text(TranslationServer.translate(modeLabel))
	var difLabel = "DIFFICULTY"+str(gameDifficulty)
	get_node("options/grid/difficultyBtn").set_text(TranslationServer.translate(difLabel))
	get_node("options/grid/localeBtn").set_text(TranslationServer.translate("LOCALE"))
	get_node("options/backBtn").set_text(TranslationServer.translate("BACK"))
	var txt = TranslationServer.translate("description_mode_"+str(gameMode))
	if gameMode == 1:
		txt = txt.replace("XXXX", str(initialTimer[gameMode][gameDifficulty]))
	get_node("options/gamemode").set_text(txt)

	get_node("titlescreen/Grid/helpBtn").set_text(TranslationServer.translate("HELP"))
	get_node("titlescreen/Grid/optionBtn").set_text(TranslationServer.translate("OPTIONS"))
	get_node("titlescreen/Grid/playBtn").set_text(TranslationServer.translate("PLAY"))
	get_node("titlescreen/Grid/exitBtn").set_text(TranslationServer.translate("EXIT"))

	get_node("help/helpLabel").set_text(TranslationServer.translate("HELP"))
	get_node("help/backBtn").set_text(TranslationServer.translate("BACK"))
	get_node("help/helpText").set_text(TranslationServer.translate("HELPTEXT"))
	
	get_node("gameover/finalLabel").set_text(TranslationServer.translate("FINALSCORE"))	
	get_node("gameover/highscoreLabel").set_text(TranslationServer.translate("HIGHSCORE"))
	get_node("gameover/longestWordLabel").set_text(TranslationServer.translate("LONGWORD"))
	get_node("gameover/gotHighscore").set_text(TranslationServer.translate("HIGHSCORE"))
	get_node("gameover/continue").set_text(TranslationServer.translate("CONTINUE"))

	get_node("pause/continueBtn").set_text(TranslationServer.translate("CONTINUE"))

func toggleMusic():
	musicToggle ^= 1
	if musicToggle:
		get_node("options/grid/musicBtn").set_text(TranslationServer.translate("MUSICON"))
	else:
		get_node("options/grid/musicBtn").set_text(TranslationServer.translate("MUSICOFF"))
	if ! musicToggle:
		get_node("streamTitle").stop()
		get_node("streamGameOver").stop()
		get_node("streamGameOn").stop()
	else:
		get_node("streamGameOver").stop()
		if PLAY==1:
			get_node("streamTitle").stop()
			get_node("streamGameOn").play()
		else:
			get_node("streamTitle").play()
			get_node("streamGameOn").stop()
		
	get_node("options/grid/musicBtn").set_pressed(musicToggle)
	storeOptions()

func toggleSound():
	soundToggle ^= 1
	get_node("options/grid/soundBtn").set_pressed(soundToggle)
	if soundToggle:
		get_node("options/grid/soundBtn").set_text(TranslationServer.translate("SOUNDON"))
	else:
		get_node("options/grid/soundBtn").set_text(TranslationServer.translate("SOUNDOFF"))	

		storeOptions()

func toggleGameMode():
	gameMode = (gameMode+1) % 3
	var modeLabel = "MODE"+str(gameMode)
	get_node("options/grid/modeBtn").set_text(TranslationServer.translate(modeLabel))
	var txt = TranslationServer.translate("description_mode_"+str(gameMode))
	if gameMode == 1:
		txt = txt.replace("XXXX", str(initialTimer[gameMode][gameDifficulty]))
	get_node("options/gamemode").set_text(txt)
	storeOptions()
		
func toggleDifficulty():	
	gameDifficulty = (gameDifficulty+1) % 2
	var difLabel = "DIFFICULTY"+str(gameDifficulty)
	get_node("options/grid/difficultyBtn").set_text(TranslationServer.translate(difLabel))
	var txt = TranslationServer.translate("description_mode_"+str(gameMode))
	if gameMode == 1:
		txt = txt.replace("XXXX", str(initialTimer[gameMode][gameDifficulty]))
	get_node("options/gamemode").set_text(txt)
	storeOptions()

func toggleLocale():
	currentLocale = (currentLocale + 1) % _localeCount
	options.locale = locale[currentLocale]
	storeOptions()
	TranslationServer.set_locale(options.locale)
	setTranslations()
	

func _ready():
	randomize()
	options = load("res://options.gd").new()
	get_node("version").set_text(_VERSION+_COPYRIGHT)
	get_node("titlescreen/version").set_text(_VERSION)
	if (options.localeIdx == null) || (options.localeIdx < 0) && (options.localIdx >= _localeCount):
		options.localeIdx = 0
	options.locale = locale[options.localeIdx]
	currentLocale = options.localeIdx
	if (options.highScore) != null  && (options.highScore.size() == highScore.size()):
		highScore = options.highScore
		
	if options.sfx != null:
		soundToggle = options.sfx
		
	if options.music != null:
		musicToggle = options.music
		
	if options.gameMode != null:
		gameMode = options.gameMode

	if options.gameDifficulty != null:
		gameDifficulty = options.gameDifficulty
		
	TranslationServer.set_locale(options.locale)
	setTranslations()

	if ! musicToggle:
		get_node("streamTitle").stop()
		get_node("streamGameOver").stop()
		get_node("streamGameOn").stop()
	get_node("options/grid/musicBtn").set_pressed(musicToggle)
	get_node("options/grid/soundBtn").set_pressed(soundToggle)

	get_node("titlescreen/Grid/playBtn").connect("pressed", self, "play")
	get_node("titlescreen/Grid/exitBtn").connect("pressed", self, "getOut")
	get_node("titlescreen/Grid/optionBtn").connect("pressed", self, "options")
	get_node("titlescreen/Grid/helpBtn").connect("pressed", self, "help")
	get_node("options/backBtn").connect("pressed", self, "titleMenu")
	get_node("options/grid/musicBtn").connect("pressed", self, "toggleMusic")
	get_node("options/grid/soundBtn").connect("pressed", self, "toggleSound")
	get_node("options/grid/modeBtn").connect("pressed", self, "toggleGameMode")
	get_node("options/grid/difficultyBtn").connect("pressed", self, "toggleDifficulty")
	get_node("options/grid/localeBtn").connect("pressed", self, "toggleLocale")
	get_node("pause/continueBtn").connect("pressed", self, "unpause")
	get_node("keyTimer").connect("timeout",self,"resetKeyPressed")
	get_node("help/backBtn").connect("pressed", self, "titleMenu")
	get_node("streamTitle").play()
	get_node("streamGameOver").stop()
	get_node("streamGameOn").stop()

	scoreNode = get_node("scoreDisplay")
	sfxNode = get_node("sfxNode")
	lgWdNode = get_node("longuestWord")
	crtWdNode = get_node("currentWord")
	lstWdNode = get_node("lastWord")
	timerNode = get_node("timer")
	progressionBar = get_node("progressionBar")
	gameTimer=get_node("gameTimer")
	gameTimer.connect("timeout", self, "_time_out")
	titleMenu()
	
func titleMenu():
	fireworks(false)
	setScene("titlescreen")
	if musicToggle && (! doNotRestartMusic):
		get_node("streamTitle").play()
		get_node("streamGameOver").stop()
		get_node("streamGameOn").stop()
	doNotRestartMusic = false
				
func play():
	if PLAY == true:
		return
	setTranslations()
	setScene("game")
		
	timer = initialTimer[gameMode][gameDifficulty]
	lastTimer = timer
	selectedTiles = []
	lastTile = [-1,-1]
	createdWord = ""
	selectedTileCnt = 0
	score = 0
	longestWord = ""
	level = 1
	nextLevelAt = 200
	oldLevelAt = 0
	get_node("streamTitle").stop()
	get_node("titlescreen").hide()
	PLAY = true
	var sX = _startX
	var sY = _startY
	get_node("levelWord").set_text(str(level))
	lstWdNode.set_text("")
	lgWdNode.set_text("")
	crtWdNode.set_text("")
	scoreNode.set_text("0")
	progressionBar.setProgression(score-oldLevelAt, nextLevelAt-oldLevelAt)
	
	if gameMode != 2:
		gameTimer.start()
	else:
		timerNode.set_text("")
	grid.resize(_sizeX*_sizeY)
	stars.resize(_sizeX*_sizeY)
	selectedTiles.resize(_sizeX*_sizeY)
	lowestOrderedPerX.resize(_sizeX)
	for i in range(0,_sizeX):
		lowestOrderedPerX[i] = {}
		
	for i in range(_sizeX*_sizeY):
		selectedTiles[i] = [-1,-1,null]
	print("maxRuneProbability : ",stats.maxRuneProbability)
	for i in range(_sizeY):
		for s in range (_sizeX):
			var dup = tile.instance()
			var rune = chooseRune()
			add_child(dup)
			dup.set_pos(Vector2(sX,sY))
			dup.set_text(rune)
			var params = [dup, s, i]
			dup.connect("pressed", self, "_on_tile_pressed", params)
			grid[(i*_sizeX+s)]=dup
			dup = starsPrtcl.instance()
			add_child(dup)
			dup.set_pos(Vector2(sX+_halfTileSize,sY+_halfTileSize))
			stars[(i*_sizeX+s)]=dup
			sX += _tileSize
		sX = _startX
		sY += _tileSize
	for i in range(_sizeY*_sizeX):
		stars[i].raise()
		
	set_process_input(true)
	if musicToggle:
		get_node("streamTitle").stop()
		get_node("streamGameOver").stop()
		get_node("streamGameOn").play()
		
func chooseRune():
	if PLAY != true:
		return
	var runeSelector = rand_range(0, stats.maxRuneProbability)
	var lowest = stats.maxRuneProbability
	for r in stats.dictStats:
		if (runeSelector <= r) && (r < lowest):
			lowest = r
	return stats.dictStats[lowest]

func notInSelected(x, y):
	if PLAY != true:
		return
	for i in range(0,selectedTileCnt):
		var st = selectedTiles[i]
		if (st[0] == x) && (st[1] == y):
			return false
	return true

func clearSelected():
	if PLAY != true:
		return
	print("Entering clearSelected")
	for i in range(0,selectedTileCnt):
		if selectedTiles[i] != [-1,-1,null]:
			selectedTiles[i][2].set_pressed(false)
		selectedTiles[i] = [-1,-1,null]
	selectedTileCnt=0
	createdWord = ""
	selectedTileCnt = 0
	lastTile = [-1,-1]
	crtWdNode.set_text(createdWord)
	print("done")
	
func _on_tile_pressed(btn, x, y):	
	if PLAY != true:
		return
	var txt = btn.get_text()
	if ((lastTile[0] == -1) || (lastTile[1] == -1)) || (x<=(lastTile[0]+1)) && (x>=(lastTile[0]-1)) && (y<=(lastTile[1]+1)) && (y>=(lastTile[1]-1)) && ((lastTile[0] != x) || (lastTile[1] != y)) && (notInSelected(x,y)):
		lastTile = [x,y]
		btn.set_pressed(true)
		selectedTiles[selectedTileCnt]=[x,y,btn]
		selectedTileCnt += 1
		createdWord = createdWord + txt
		crtWdNode.set_text(createdWord)
	elif (lastTile[0] == x) && (lastTile[1] == y):
		btn.set_pressed(true)
		var wordExists = checkWord(createdWord)
		print("Word : ",createdWord)
		print("Exists : ", wordExists)
		if wordExists:
			if soundToggle:
				sfxNode.play("wordfound", false)
			lstWdNode.set_text(createdWord)
			var mult = ((createdWord.length()-3)*10)
			if mult == 0:
				mult = 1				
			score += selectedTileCnt*mult
			scoreNode.set_text(str(score))
			if createdWord.length() > longestWord.length():
				longestWord = createdWord
				lgWdNode.set_text(longestWord)
			destroyAndFall()
			clearSelected()
			if	gameMode == 1:
					timer = initialTimer[gameMode][gameDifficulty]
			if score >= nextLevelAt:
				gameTimer.stop()
				level = level + 1
				oldLevelAt = nextLevelAt
				nextLevelAt = nextLevelAt+(level * 100)				
				get_node("levelWord").set_text(str(level))
				if soundToggle:
					sfxNode.play("levelup", false)
				if gameMode == 0:					
					timer = (60/(1+gameDifficulty))+ceil(60.0*(float(level)/((gameDifficulty+1)*2.0)))
				rebuildGrid()
				if gameMode != 2:
					gameTimer.start()
			progressionBar.setProgression(score-oldLevelAt, nextLevelAt-oldLevelAt)
			
	else:
		clearSelected()
		print("CLEARED")
		lastTile = [x,y]
		selectedTiles[selectedTileCnt]=[x,y,btn]
		selectedTileCnt = 1
		createdWord = txt
		
func destroyAndFall():
	if PLAY != true:
		return
	# DESTROY
	for i in range(0,selectedTileCnt):
		var x = selectedTiles[i][0]
		var y =selectedTiles[i][1]
		selectedTiles[i][2].set_text("")
		stars[y*_sizeX+x].set_emitting(true)

		var keys = lowestOrderedPerX[x].keys()
		var highest = -1
		if ! keys.empty():
			var tmpOrder = 1000
			highest = lowestOrderedPerX[x][_HIGHEST]
			keys.sort()
			for k in keys:
				if k == _HIGHEST:
					continue
				if y < lowestOrderedPerX[x][k][1]:
					tmpOrder = k - 50
				elif y == lowestOrderedPerX[x][k][1]:
					tmpOrder = k - 1
					break
				else:
					tmpOrder = k+50
			lowestOrderedPerX[x][tmpOrder] = selectedTiles[i]
		else:
			lowestOrderedPerX[x][500]=selectedTiles[i]
		if y > highest:
			lowestOrderedPerX[x][_HIGHEST] = y
	# FALL
	var c = ""
	var rrange = []
	for x in range(0,_sizeX):
		if lowestOrderedPerX[x].empty():
			continue
		c = ""
		var rng = range(0,lowestOrderedPerX[x][_HIGHEST]+1)
		rng.invert()
		for y in rng:
			c = rcsvGetLetterAbove(x,y)
			if c == "":
				c = chooseRune()
			grid[y*_sizeX+x].set_text(c)
			
		
func rcsvGetLetterAbove(x,y):
	if PLAY != true:
		return
	var idx = y*_sizeX+x
	var cnt = grid[idx].get_text()
	if cnt != "":
		grid[idx].set_text("")
		return cnt
	else:
		y = y -1
		if y < 0:
			return ""
		else:
			return rcsvGetLetterAbove(x,y)
	
func checkWord(w):
	if PLAY != true:
		return
	if w.length() < 3:
		return false
	var prefix = w.substr(0,3)
	if ! refs.dictRefs.has(prefix):
		return false
	var fh = File.new()
	fh.open("res://dicts/"+options.locale+"/"+refs.dictRefs[prefix], 1)
	var cnt = fh.get_as_text()
	fh.close()
	var rs = cnt.find("\n"+w+"\n",0)
	if rs == -1:
		rs = cnt.find(w+"\n",0)
	if rs > -1:
		return true
	else:
		return false
