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

extends Sprite

const _sizeX = 215
const _sizeY = 1
const _height = 15


var frame = 0
var maxFrames = 215
var timer = null
var currentPct = 0

func _animate():
	set_region_rect(Rect2(0, (_sizeY*frame), currentPct, _height))	
	frame = frame+1
	if frame > maxFrames:
		frame = 0

func _ready():
	set_region_rect(Rect2( 0, 0, 0, _height))
	timer = get_node("timer")
	timer.connect("timeout",self,"_animate")
	timer.start()
	
func setProgression(v, maxV):
	currentPct = int(floor( v * _sizeX / maxV))
	print(currentPct)
