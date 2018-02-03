extends Control

var font = .get_font('font')
var lines = []
var globalY = 0
var text_color = Color()
var of = Vector2()

func _ready():
	pass

func ex_update(a,b,c,d,e):
	font = a
	lines = b
	globalY = c
	text_color = d
	of = e
	update()

func _draw():
	var y = globalY
	for l in lines:
		draw_string(font,Vector2(l[0],y)+of,l[1], text_color)
		y += l[2]
