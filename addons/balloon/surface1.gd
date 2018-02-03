extends Control

var p

func _ready():
	rect_size = Vector2(16,16)

func ex_update(p):
	self.p = p
	update()

func _draw():
	if not p:
		return
	
	draw_set_transform(p._offset, 0, Vector2(1,1))
	
	# shadow
	draw_primitive( p._arrow_vertices_shadow, p._arrow_colors_shadow, p._arrow_uvs, null)
	for i in range(p.vertices.size()):
		draw_primitive( p.vertices_shadow[i],p.colors_shadow[i],p.uvs[i],null )
	
	# background
	draw_primitive( p._arrow_vertices, p._arrow_colors, p._arrow_uvs, null)
	for i in range(p.vertices.size()):
		draw_primitive( p.vertices[i],p.colors[i],p.uvs[i],null )
