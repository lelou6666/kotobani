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

const _VERSION = "alpha_8"
	
func _ready():
	var options = load("res://options.gd").new()
	get_node("version").set_text(_VERSION)
	print("locale :",options.locale)
	TranslationServer.set_locale(options.locale)
	get_node("Grid/helpBtn").set_text(TranslationServer.translate("HELP"))
	get_node("Grid/optionBtn").set_text(TranslationServer.translate("OPTIONS"))
	get_node("Grid/playBtn").set_text(TranslationServer.translate("PLAY"))
	get_node("Grid/exitBtn").set_text(TranslationServer.translate("EXIT"))
