extends Node2D

const _VERSION = "alpha_6b\ncopyright 2014 Sammy Fischer\n(sammy@cosmic-bandito.com)\nDO NOT REDISTRIBUTE!"

# member variables here, example:
# var a=2
# var b="textvar"
const _startX = 224
const _startY = 0
const _sizeX = 16
const _sizeY = 12
const _tileSize = 50
const _halfTileSize = 25
const _HIGHEST = 999999

var grid = []
var stars = []

var tile = preload("res://tile.scn")
var starsPrtcl = preload("res://particles_rainbow.scn")

var selectedTiles = []
var lastTile = [-1,-1]
var createdWord = ""
var selectedTileCnt = 0
var score = 0
var scoreNode = null
var sfxNode = null
var lgWdNode = null
var crtWdNode = null
var lstWdNode = null

var soundToggle = 1
var musicToggle = 1
var level = 1
var nextLevelAt = 200
var longestWord = ""

var lowestOrderedPerX = []

var language = null

var stats = null
var refs = null

func _input(e):
	if e.is_action("clear_selected"):
		createdWord = ""
		lastTile = [-1,-1]
		clearSelected()
		selectedTileCnt = 0
		return
	if e.is_action("toggle_sound"):
		soundToggle = soundToggle ^ 1
		return
	if e.is_action("toggle_music"): 
		musicToggle = musicToggle ^ 1
		if musicToggle == 1:
			get_node("streamNode").play()
		else:
			get_node("streamNode").stop()
		return

func rebuildGrid():
	for i in range(_sizeX*_sizeY):
		selectedTiles[i] = [-1,-1,null]
	for i in range(_sizeY):
		for s in range (_sizeX):
			grid[(i*_sizeX+s)].set_text(chooseRune())
			stars[i*_sizeX+s].set_emitting(true)
			

func _ready():
	randomize()

	language = load("res://language.gd").new()
	stats = load("res://dicts/"+language.locale+"/stats.gd").new()
	refs = load("res://dicts/"+language.locale+"/references.gd").new()
	get_node("version").set_text(_VERSION)
	print("locale :",language.locale)
	TranslationServer.set_locale(language.locale)
	
	
	var sX = _startX
	var sY = _startY
	get_node("lastword-label").set_text(TranslationServer.translate("LASTWORD")+" :")
	get_node("longest-label").set_text(TranslationServer.translate("LONGWORD")+" :")
	get_node("buffer-label").set_text(TranslationServer.translate("BUFFER")+" :")
	get_node("score-label").set_text(TranslationServer.translate("SCORE")+" :")
	get_node("level-label").set_text(TranslationServer.translate("LEVEL")+" :")
	get_node("levelWord").set_text(str(level))
	scoreNode = get_node("scoreDisplay")
	sfxNode = get_node("sfxNode")
	lgWdNode = get_node("longuestWord")
	crtWdNode = get_node("currentWord")
	lstWdNode = get_node("lastWord")
	get_node("timer").set_text("")
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
	set_process_input(true)
		
func chooseRune():
	var runeSelector = rand_range(0, stats.maxRuneProbability)
	var lowest = stats.maxRuneProbability
	for r in stats.dictStats:
		if (runeSelector <= r) && (r < lowest):
			lowest = r
	return stats.dictStats[lowest]

func notInSelected(x, y):
	for i in range(0,selectedTileCnt):
		var st = selectedTiles[i]
		if (st[0] == x) && (st[1] == y):
			return false
	return true

func clearSelected():
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
			if soundToggle == 1:
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
			if score >= nextLevelAt:
				level = level + 1
				nextLevelAt = nextLevelAt+(level * 100)
				get_node("levelWord").set_text(str(level))
				sfxNode.play("levelup", false)
				print("next level at : ",nextLevelAt)
				rebuildGrid()
			
	else:
		clearSelected()
		print("CLEARED")
		lastTile = [x,y]
		selectedTiles[selectedTileCnt]=[x,y,btn]
		selectedTileCnt = 1
		createdWord = txt
		
func destroyAndFall():
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
	if w.length() < 3:
		return false
	var prefix = w.substr(0,3)
	if ! refs.dictRefs.has(prefix):
		return false
	var fh = File.new()
	fh.open("res://dicts/"+language.locale+"/"+refs.dictRefs[prefix], 1)
	var cnt = fh.get_as_text()
	fh.close()
	var rs = cnt.find("\n"+w+"\n",0)
	if rs == -1:
		rs = cnt.find(w+"\n",0)
	if rs > -1:
		return true
	else:
		return false
