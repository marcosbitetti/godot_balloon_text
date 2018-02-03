extends Control

var vertices = []
var colors = []
var uvs = []
var vertices_shadow = []
var colors_shadow = []
var _arrow_vertices = []
var _arrow_colors = []
var _arrow_uvs = []
var _arrow_vertices_shadow = []
var _arrow_colors_shadow = []

func _ready():
	pass

func ex_update(a,b,c,d,e,f,g,h,i,j):
	vertices = a
	colors = b
	uvs = c
	vertices_shadow = d
	colors_shadow = e
	_arrow_vertices = f
	_arrow_colors = g
	_arrow_uvs = h
	_arrow_vertices_shadow = i
	_arrow_colors_shadow = j
	update()

func _draw():
	# shadow
	draw_primitive( _arrow_vertices_shadow, _arrow_colors_shadow, _arrow_uvs, null)
	for i in range(vertices.size()):
		draw_primitive( vertices_shadow[i],colors_shadow[i],uvs[i],null )
	
	# background
	draw_primitive( _arrow_vertices, _arrow_colors, _arrow_uvs, null)
	for i in range(vertices.size()):
		draw_primitive( vertices[i],colors[i],uvs[i],null )
