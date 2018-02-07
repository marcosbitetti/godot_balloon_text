extends Control

var p

func _ready():
	rect_size = Vector2(16,16)

func ex_update(p):
	self.p = p
	update()
	
func _draw():
	if not p or not is_inside_tree():
		return
	
	if p.vertices.size()==0:
		return
	
	var scale = Vector2(1,1)/get_global_transform().basis_xform_inv(Vector2(1,1))
	draw_set_transform(p._offset*scale, 0, scale)
		
	var y = p.globalY
	for l in p.lines:
		draw_string(p.font,Vector2(l[0],y)+p.of,l[1], p.text_color)
		y += l[2]
