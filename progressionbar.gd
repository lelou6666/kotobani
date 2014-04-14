extends Sprite

const _sizeX = 215
const _sizeY = 14

var frame = 0
var maxFrames = 15
var timer = null
var currentPct = 0

func _animate():
	set_region_rect(Rect2(0, (_sizeY*frame), currentPct, _sizeY))	
	frame = frame+1
	if frame > maxFrames:
		frame = 0

func _ready():
	set_region_rect(Rect2( 0, 0, 0, _sizeY))
	timer = get_node("timer")
	timer.connect("timeout",self,"_animate")
	timer.start()
	
func setProgression(v, maxV):
	currentPct = int(floor( v * _sizeX / maxV))
	print(currentPct)
