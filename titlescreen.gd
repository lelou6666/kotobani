extends Sprite

const _VERSION = "alpha_8"
	
func _ready():
	var language = load("res://language.gd").new()
	get_node("version").set_text(_VERSION)
	print("locale :",language.locale)
	TranslationServer.set_locale(language.locale)
	get_node("Grid/helpBtn").set_text(TranslationServer.translate("HELP"))
	get_node("Grid/optionBtn").set_text(TranslationServer.translate("OPTIONS"))
	get_node("Grid/playBtn").set_text(TranslationServer.translate("PLAY"))
	get_node("Grid/exitBtn").set_text(TranslationServer.translate("EXIT"))
