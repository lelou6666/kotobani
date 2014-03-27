
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
const _startX = 224
const _startY = 0
const _sizeX = 8
const _sizeY = 6

var grid = []
var tile = preload("res://Tile.scn")
var DEBUG = ["a","b","c"]

func _ready():
	# Initalization here
	var sX = _startX;
	var sY = _startY;
	grid.resize(_sizeX*_sizeY)
	var stats = load("res://dicts/de_DE/stats.csv")
	var dicts = load("res://dicts/de_DE/references.csv")

#	var lbl = Button.new()
#	add_child( lbl)
#	lbl.set_pos(Vector2(300, 300))
#	lbl.set_size(Vector2(100,100))
#	lbl.set_text("HALLLLOOOOOOO")
	var dbg = 0
	print("stats : "+stats)
	for i in range(_sizeY):
		for s in range (_sizeX):
			var dup = tile.instance()
			add_child(dup)
			dup.set_pos(Vector2(sX,sY))
			dup.set_text(DEBUG[dbg])
			dbg += 1
			dbg %= 3
			var params = [dup.get_text(), i, s]
			print("Connecting with : "+params[0])
			dup.connect("pressed", self, "_on_tile_pressed", params)
			grid[(i*_sizeX+s)]=dup
			sX += 100;
		sX = _startX;
		sY += 100;
		
func _on_tile_pressed(txt, x, y):
	print(">> PARAMS:"+txt)
