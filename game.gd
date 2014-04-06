
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
const _startX = 224
const _startY = 0
const _sizeX = 8
const _sizeY = 6
const _HIGHEST = 999999

var grid = []
var tile = preload("res://tile.scn")
var arrows = preload("res://arrows.scn")

var stats = preload("res://dicts/de_DE/stats.gd").new()
var refs = preload("res://dicts/de_DE/references.gd").new()

var selectedTiles = []
var lastTile = [-1,-1]
var createdWord = ""
var selectedTileCnt = 0
var score = 0
var scoreNode = null

var lowestOrderedPerX = []

func _ready():
	randomize()
	var sX = _startX
	var sY = _startY
	scoreNode = get_node("scoreDisplay")
	grid.resize(_sizeX*_sizeY)
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
			sX += 100
		sX = _startX
		sY += 100
		
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
	print("done")
	
func _on_tile_pressed(btn, x, y):
	var txt = btn.get_text()
	if ((lastTile[0] == -1) || (lastTile[1] == -1)) || (x<=(lastTile[0]+1)) && (x>=(lastTile[0]-1)) && (y<=(lastTile[1]+1)) && (y>=(lastTile[1]-1)) && ((lastTile[0] != x) || (lastTile[1] != y)) && (notInSelected(x,y)):
		lastTile = [x,y]
		selectedTiles[selectedTileCnt]=[x,y,btn]
		selectedTileCnt += 1
		createdWord = createdWord + txt
	elif (lastTile[0] == x) && (lastTile[1] == y):
		var wordExists = checkWord(createdWord)
		print("Word : ",createdWord)
		print("Exists : ", wordExists)
		if wordExists:
			destroyAndFall()
			score += selectedTileCnt
			scoreNode.set_text(str(score))
			createdWord = ""
			lastTile = [-1,-1]
			clearSelected()
			selectedTileCnt = 0
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
		selectedTiles[i][2].set_text("")
		var y =selectedTiles[i][1]
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
		print("x:",x)
		print("lowestOrdered:",lowestOrderedPerX[x])
		if lowestOrderedPerX[x].empty():
			print("empty")
			continue
		c = ""
		print("Highest Y:",lowestOrderedPerX[x][_HIGHEST])
		var rng = range(0,lowestOrderedPerX[x][_HIGHEST]+1)
		rng.invert()
		for y in rng:
			print("y:",y)
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
	fh.open("res://dicts/de_DE/"+refs.dictRefs[prefix], 1)
	var cnt = fh.get_as_text()
	fh.close()
	var search = "\n"+w+"\n"
	if w.length() == 3:
		search = w+"\n" 
	var rs = cnt.find(search,0)
	if rs > -1:
		return true
	else:
		return false
