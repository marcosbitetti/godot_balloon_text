extends Control

var p

func _ready():
	rect_size = Vector2(16,16)

func ex_update(p):
	self.p = p
	update()
	
func _draw():
	if not p:
		return print('no exsst')
		
	var y = p.globalY
	for l in p.lines:
		draw_string(p.font,Vector2(l[0],y)+p.of,l[1], p.text_color)
		y += l[2]
