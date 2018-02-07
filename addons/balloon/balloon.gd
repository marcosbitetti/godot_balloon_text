######################################################################################################
#
#                   This work is licensed under a Creative Commons Attribution 4.0
#                                      International License.
#               Based on a work at https://github.com/marcosbitetti/godot_balloon_text.
#
# <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License"
# style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is 
# licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons 
# Attribution 4.0 International License</a>.<br />Based on a work at <a 
# xmlns:dct="http://purl.org/dc/terms/" href="https://github.com/marcosbitetti/godot_balloon_text" 
# rel="dct:source">https://github.com/marcosbitetti/godot_balloon_text</a>.
#
######################################################################################################
#

tool
extends Control

# font normal_font bold_font italics_font bold_italics_font mono_font default_color 

export(String) var text = "" setget _set_text
export(float) var ratio = 1.0 setget _set_ratio
export(int) var font_height_adjust = 0 setget _set_font_height_adjust
export(int) var padding = 8 setget _set_padding
export(int) var shadown_width = 4 setget _set_shadown_width
export(Color) var text_color = Color(0,0,0,1) setget _set_text_color
export(Color) var color = Color(1,1,1,1) setget _set_color
export(Color) var color_center = Color(1,1,1,1) setget _set_color_center
export(Color) var color_shadow = Color(0,0,0,1) setget _set_color_shadow
export(float) var arrow_width = 0.25 setget _set_arrow_width
export(Font) var normal_font = null setget _set_font
#export(Font) var bold_font
#export(Font) var italics_font
#export(Font) var bold_italics_font
#export(Font) var mono_font
export(NodePath) var lock_target = null setget _set_target
export(int) var words_per_minute = 200 # world median words readed by minute
export(bool) var auto_hide = true
export(Material) var balloon_material = null setget _set_balloon_material
export(Material) var text_material = null setget _set_text_material

export var show_debug_messages = false

const RESOLUTION = 48.0

var vertices = Array()
var colors = Array()
var vertices_shadow = Array()
var colors_shadow = Array() 
var uvs = Array()
var _arrow_vertices = Array()
var _arrow_colors = Array()
var _arrow_vertices_shadow = Array()
var _arrow_colors_shadow = Array()
var _arrow_uvs = Array()
var of = Vector2()
var _offset = Vector2()
var area = 0.0
var rad = 0.0
var font = null
var lines = []
var globalY = 0
var arrow_target = null
var extra_offset = Vector2()
var _is3D = false
var old_tg_pos = Vector2()
var _arrow_target = Vector2()
var delay = 0
var is_opened = false
var _stream = null
#var _surface1 = preload("res://addons/balloon/background.tscn").instance()
var _surface1 = preload("res://addons/balloon/surface1.gd").new()
var _surface2 = preload("res://addons/balloon/surface2.gd").new()

	
####################
#
#  Gettes/Setters
#
####################

# helper to dismiss a lot of this same IF
func __need_update():
	if text and text.length()>0:
		render_text(text)
	update()
	
# set target from string
func _set_target(name=""):
	if not name or name=="":
		lock_target = null
		arrow_target = null
		_arrow_target = Vector2()
		update()
		return
		
	var lt = str(name)
	if lt.find('/') != 0:
		lt = '../' + lt
	if has_node(lt):
		var obj = get_node(lt)
		if obj:
			target(obj)
			update()
	lock_target = name

func _set_text(txt):
	if not txt:
		txt = ""
	text = txt
	if txt == "" and not Engine.editor_hint:
		hide()
	else:
		render_text(txt)
		update()

func _set_font(fnt):
	if not fnt:
		print('a ',.get_font('font'))
		fnt = .get_font('font')
	normal_font = fnt
	__need_update()

func _get_font():
	#return get_font('normal_font')
	normal_font

func _set_ratio(r):
	ratio = float(r)
	__need_update()
	
func _set_padding(p):
	padding = float(p)
	__need_update()

func _set_font_height_adjust(v):
	font_height_adjust = float(v)
	__need_update()

func _set_shadown_width(w):
	shadown_width = float(w)
	__need_update()
	
func _set_text_color(c):
	text_color = c
	__need_update()

func _set_color(c):
	color = c
	__need_update()

func _set_color_center(c):
	color_center = c
	__need_update()	

func _set_color_shadow(c):
	color_shadow = c
	__need_update()

func _set_arrow_width(w):
	arrow_width = float(w)
	__need_update()

func _set_balloon_material(m):
	if _surface1:
		_surface1.material = m
	balloon_material = m
	__need_update()

func _set_text_material(m):
	if _surface2:
		_surface2.material = m
	text_material = m
	__need_update()

#
# set a target object
func target(obj):
	var c = obj.get_class()
	while true:
		var p = ClassDB.get_parent_class(c)
		if show_debug_messages:
			printt('object class: ', c, "\nparent class: ",p)
		if c=='Spatial' or p=='Spatial':
			_is3D = true
			break
		elif c=='Node2D' or p=='Node2D':
			_is3D = false
			break
		elif c=='Control' or p=='Control':
			var nd = Node2D.new()
			nd.position = obj.rect_size / 2.0
			nd.set_meta('balloon_arrow_target',true)
			obj.add_child(nd)
			obj = nd
			break
		c = p
		if p=='Object':
			break
		
	if arrow_target:
		if arrow_target.get_meta('balloon_arrow_target'):
			arrow_target.queue_free()			
	arrow_target = obj
	
	if obj:
		set_process(true)
	else:
		set_process(false)


#
# Render spoked text
# return time in seconds that baloon remains visible
#
func say(txt, time=null):
	var words = render_text(txt)
	if time==null:
		time = (float(words) / float(words_per_minute)) * 60
	delay = time
	set_process(true)
	is_opened = true
	update()
	show()
	
	return time

#
# Render spoked text and waithing a stream to end
# return time in seconds that baloon remains visible
#
func sat_with_stream(txt, stream):
	var t = say(txt)
	if stream:
		delay = 1000
		_stream = stream
	return -1

#
# Render spoked text, and whait user interation
# return time in seconds that baloon remains visible
#
func ask(txt, okText = null, okFunc = null, cancelText = null, cancelFunc = null):
	var t = say(txt)
	delay = 1000
	
	return -1



#
# Overrides get_font
#
func get_font(fnt):
	match fnt:
		#'bold_font': return bold_font
		#'italics_font': return italics_font
		#'bold_italics_font': return bold_italics_font
		#'mono_font': return mono_font
		_: return normal_font #normal_font
	
func render_text(txt):
	var _ratio = Vector2(1.0/ratio, ratio)
	var arr1 = txt.strip_edges().split(" ")
	var letters = 0
	var longString = ''
	var words = []
	lines.clear()
	for k in arr1:
		var tk
		if k.find("\n")>-1:
			if show_debug_messages:
				for k2 in k.split("\n"):
					
					print(k2)
		else:
			tk = k
			letters += tk.length() + 1
		words.append([tk])
		longString += tk
	
	# area
	font = get_font("normal_font")
	if not font:
		font = .get_font('font')
	
	var _area = font.get_string_size(longString)
	area = float(_area.x * _area.y)
	rad = sqrt(float(area) / PI) * 1.00 + font.get_height()
	
	#
	# render text
	#
	var x = 0
	var y = ( -rad *_ratio.y ) + (font.get_height() * _ratio.y - font.get_descent())
	var w = 0
	var end = words.size()
	var spc = font.get_string_size(" ")
	var c_rad = rad
	
	while w<end: #y<=rad:
		#var corda = round(rad * cos(abs(y)/rad))
		var f = ( rad - abs(y) ) # * _ratio.y
		var corda = 2.0 * round( sqrt( abs(f * (2.0 * rad - f)) ) ) * _ratio.x
		var st = ''
		x = 0
		while w<end: #x<corda and w<end:
			var old_st = st
			var old_x = x
			st += words[w][0]
			x = font.get_string_size(st).x # + spc.x
			st += " "
			if x>corda:
				st = old_st
				x = old_x
				break
			else:
				w += 1
		var c = -x*0.5 # (2.0*rad - x)*0.5
		#draw_string( font, Vector2(c,y), st, Color(0,0,0,1) )
		lines.append([c,st,font.get_height()])
		if show_debug_messages:
			printt("String size is: ", font.get_string_size(" "))
		y += font.get_height() * _ratio.x
		if show_debug_messages:
			printt(corda,x, x*_ratio.y*0.5, rad,st, _ratio)
		if (x*_ratio.y*0.5 + padding) > c_rad:
			c_rad = rad + ((x*_ratio.y*0.5 + padding) - rad)
	y -= font.get_descent() / 2.0
	#globalY = ( (-rad) - y )/2.0 + spc.y / 2.0 + font.get_ascent()*0.5 - font.get_descent()*0.5
	#globalY *= _ratio.y
	#globalY = -((float(lines.size()) * font.get_height())*0.5) + font.get_height()*0.5*_ratio.y + font.get_ascent()*0.5*_ratio.y - font.get_descent()*0.5*_ratio.y - font_height_adjust
	#globalY = -((float(lines.size()) * font.get_height())*0.5) + font.get_ascent() + font.get_descent() - font_height_adjust
	globalY = -((float(lines.size()) * font.get_height() - font.get_ascent() - font.get_descent())*0.5) + font_height_adjust
	
	#if c_rad != rad:
	#	rad = c_rad
	if show_debug_messages:
		print(rad)
	
	# render ballon
	var resolution = RESOLUTION
	var a = (PI*2)/resolution
	var p = padding * font.get_string_size(" ").y
	vertices.clear()
	colors.clear()
	uvs.clear()
	#arrow_index = vertices.size()
	vertices.append( [Vector2(0,0),Vector2(0,0),Vector2(0,0)] )
	colors.append( [color_center,color,color] )
	uvs.append([Vector2(0.5,0.5),Vector2(0.5,0.5),Vector2(0.5,0.5)])
	var _rad = rad + padding
	for i in range(resolution):
		var x0 = rad*_ratio.x + cos(a*i)*_rad * _ratio.x
		var y0 = rad*_ratio.y + sin(a*i)*_rad * _ratio.y
		var x1 = rad*_ratio.x + cos((a*i)+a)*_rad * _ratio.x
		var y1 = rad*_ratio.y + sin((a*i)+a)*_rad * _ratio.y
		vertices.push_back( [Vector2(rad*_ratio.x,rad*_ratio.y), Vector2(x0,y0), Vector2(x1,y1)] )
		colors.push_back( [color_center,color,color] )
		uvs.push_back([Vector2(0.5,0.5),Vector2(0.5+cos(a*i)*0.5,0.5+sin(a*i)*0.5),Vector2(0.5+cos((a*i)+a)*0.5,0.5+sin((a*i)+a)*0.5)])
	
	a = (PI*2)/resolution
	vertices_shadow.clear()
	colors_shadow.clear()
	vertices_shadow.append( [Vector2(0,0),Vector2(0,0),Vector2(0,0)] )
	colors_shadow.append( [color_shadow,color_shadow,color_shadow] )
	for i in range(resolution):
		var x0 = rad*_ratio.x + cos(a*i)*_rad * _ratio.x + cos(a*i) * shadown_width
		var y0 = rad*_ratio.y + sin(a*i)*_rad * _ratio.y + sin(a*i) * shadown_width
		var x1 = rad*_ratio.x + cos((a*i)+a)*_rad * _ratio.x + cos((a*i)+a) * shadown_width
		var y1 = rad*_ratio.y + sin((a*i)+a)*_rad * _ratio.y + sin((a*i)+a) * shadown_width
		vertices_shadow.push_back( [Vector2(rad*_ratio.x,rad*_ratio.y), Vector2(x0,y0), Vector2(x1,y1)] )
		colors_shadow.push_back( [color_shadow,color_shadow,color_shadow] )
	
	extra_offset = Vector2(_rad,_rad) * _ratio
	
	if not arrow_target:
		update()
	
	if Engine.editor_hint and is_inside_tree():
		var s = Vector2(round(rad*2),round(rad*2))*_ratio
		s = s * Vector2(1,1)/get_global_transform().basis_xform_inv(Vector2(1,1))
		s = Vector2(abs(int(s.x)),abs(int(s.y)))
		rect_size = s
		printt(s)
	
	return words.size()

func _draw():
	var _ratio = Vector2(1.0/ratio, ratio)
	if Engine.editor_hint:
		draw_texture( preload("res://addons/balloon/assets/icon_balloon.png"), Vector2(-8,-8) + rect_size*0.5, Color(1,1,1,1) )
		if text=="":
			var cr = Color("#a5efac")
			#cr.a = 0.4
			#if rad>0:
			#	var r = rad #+ padding
			#	var a = 0
			#	var p = (PI*2.0) / RESOLUTION
			#	var v = Vector2(rad,0) * _ratio
			#	for i in range(RESOLUTION):
			#		a += p
			#		var n = Vector2( rad*cos(a), rad*sin(a) ) * _ratio
			#		draw_line( v,n,cr,2 )
			#		v = n
			if arrow_target and vertices.size():
				draw_line( Vector2(-3,7) + rect_size*0.5, _arrow_target, Color("#a5efac"), 1 )
			return
	
	if vertices.size()==0:
		return
		
	_arrow_vertices = [Vector2(),Vector2(),Vector2()]
	_arrow_colors = [color,color,color]
	_arrow_vertices_shadow = [Vector2(),Vector2(),Vector2()]
	_arrow_colors_shadow = [color_shadow,color_shadow,color_shadow]
	_arrow_uvs = [Vector2(0,0),Vector2(0,0),Vector2(0,0)]
	
	# draw arrow
	of = Vector2(rad*_ratio.x,rad*_ratio.y)
	var _t = _arrow_target
	if not arrow_target:
		_t = Vector2( 0,0 )
	var nor = (_t - of).normalized()
	var per = Vector2(-nor.y,nor.x)
	_arrow_vertices[0] = _t - shadown_width*nor
	_arrow_vertices[1] = per * _ratio * (rad+padding) * arrow_width + of
	_arrow_vertices[2] = per * _ratio * (-rad-padding) * arrow_width + of
	_arrow_vertices_shadow[0] = _t + shadown_width * nor
	_arrow_vertices_shadow[1] = per * (rad+padding) * arrow_width * _ratio + per * shadown_width*_ratio.x + of
	_arrow_vertices_shadow[2] = per * (-rad-padding) * arrow_width * _ratio - per * shadown_width*_ratio.x + of
	nor = (_t - of).normalized() #_t.normalized()
	per = Vector2(-nor.y,nor.x)
	_arrow_uvs[0] = Vector2(0.5,0.5) + nor*((((_t-of)).length()-padding-rad)/rad)*0.5 #+ nor*0.5
	#_arrow_uvs[0] = Vector2(0.5,0.5) + nor*0.5
	_arrow_uvs[1] = Vector2(0.5,0.5) + per * arrow_width * 0.5
	_arrow_uvs[2] = Vector2(0.5,0.5) - per * arrow_width * 0.5
	
	# adjust to fit screen
	_offset = Vector2()
	var left_top = rect_global_position #- extra_offset
	var right_bottom = rect_global_position + extra_offset*2.0
	if left_top.x<(padding + shadown_width):
		_offset.x = (padding + shadown_width) - left_top.x
	if left_top.y<(padding + shadown_width):
		_offset.y = padding + shadown_width - left_top.y
	if right_bottom.x > get_viewport().get_visible_rect().size.x:
		_offset.x = -(right_bottom.x - get_viewport().get_visible_rect().size.x)
	if right_bottom.y > get_viewport().get_visible_rect().size.y:
		_offset.y = -(right_bottom.y - get_viewport().get_visible_rect().size.y)
	draw_set_transform(_offset, 0, Vector2(1,1))
	
	# shadow
	#draw_primitive( _arrow_vertices_shadow, _arrow_colors_shadow, _arrow_uvs, null)
	#for i in range(vertices.size()):
	#	draw_primitive( vertices_shadow[i],colors_shadow[i],uvs[i],null )
	
	# background
	#draw_primitive( _arrow_vertices, _arrow_colors, _arrow_uvs, null)
	#for i in range(vertices.size()):
	#	draw_primitive( vertices[i],colors[i],uvs[i],null )
	
	#_surface2.of = of
	#printt(_surface1,_surface1.ex_update)
	#_surface1.ex_update(vertices,colors,uvs,vertices_shadow,colors_shadow,_arrow_vertices,_arrow_colors,_arrow_uvs,_arrow_vertices_shadow,_arrow_colors_shadow)
	#_surface2.ex_update(font,lines,globalY,text_color,of)
	#_surface1.update()
	#_surface2.update()
	if _surface1:
		if Engine.editor_hint:
			_surface1.emit_signal("draw")
			_surface2.emit_signal("draw")
		else:
			_surface1.ex_update(self)
			_surface2.ex_update(self)
	
	# text
	#var y = globalY
	#for l in lines:
	#	draw_string(font,Vector2(l[0],y)+of,l[1], text_color)
	#	y += l[2]



func _process(delta):
	if arrow_target:
		if _is3D:
			var cam = get_viewport().get_camera()
			if cam:
				_arrow_target = cam.unproject_position(arrow_target.global_transform.origin) - get_global_transform().origin
		else:
			_arrow_target = arrow_target.global_position - get_global_transform().origin
		if _arrow_target != old_tg_pos:
			old_tg_pos = _arrow_target
			update()
	
	if delay>0:
		delay -= delta
		if delay<0:
			delay=0
			if auto_hide:
				set_process(false)
				is_opened = false
				hide()


func _rec_changed():
	#update()
	pass

func _force_update():
	if lock_target:
		_set_target(lock_target)
	else:
		update()

func _ready():
	if not normal_font:
		#normal_font = .get_font('font')
		self.normal_font = .get_font('font')
	#if not bold_font:
	#	bold_font = .get_font('font')
	#if not italics_font:
	#	italics_font = .get_font('font')
	#if not bold_italics_font:
	#	bold_italics_font = .get_font('font')
	#if not mono_font:
	#	mono_font = .get_font('font')
	
	# surfaces
	if Engine.editor_hint:
		#_surface1.add_script(preload("res://addons/balloon/surface1.gd").get_script())
		#_surface2.add_script(preload("res://addons/balloon/surface2.gd").get_script())
		#_surface1.connect("draw",_surface1, "ex_update",[vertices,colors,uvs,vertices_shadow,colors_shadow,_arrow_vertices,_arrow_colors,_arrow_uvs,_arrow_vertices_shadow,_arrow_colors_shadow] )
		_surface1.connect("draw",_surface1, "ex_update",[self] )
		_surface2.connect("draw",_surface2, "ex_update",[self] )
	add_child(_surface1)
	add_child(_surface2)
	
	# prevent wrong initialization
	set_process(false)
	
	# if lock target exist set arrow to it
	if lock_target:
		_set_target(lock_target)
	
	if Engine.editor_hint:
		update()
		#connect("item_rect_changed",self,"_rec_changed")
		return
	
	#rect_min_size = Vector2(500,500)
	if text and text.length()>0:
		if Engine.editor_hint:
			_set_text(text)
		else:
			say(text)
	else:
		hide()