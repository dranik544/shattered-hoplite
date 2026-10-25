extends RichTextLabel

var logtext: Array = []

onready var tween = $Tween


func _init():
	add_to_group("logtext")

func _ready():
	_update_log()


func print_log(STRlogtext: String):
	logtext.append(STRlogtext)
	if logtext.size() > 4: logtext.remove(0)
	_update_log()

func _update_log():
	var logtextstring: String
	for i in logtext:
		logtextstring += str(i)
	bbcode_text = logtextstring
	
	modulate.a = 1.0
	tween.interpolate_property(self, "modulate:a", 1.0, 0.35, 3.0)
	tween.start()
