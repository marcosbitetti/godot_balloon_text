tool
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

extends Control

# font normal_font bold_font italics_font bold_italics_font mono_font default_color 

export(String) var text = ""
export(float) var ratio = 1.0
export(float) var font_height_adjust = 0
export(float) var padding = 8
export(float) var shadown_width = 4
export(Color) var text_color = Color(0,0,0,1)
export(Color) var color = Color(1,1,1,1)
export(Color) var color_center = Color(1,1,1,1)
export(Color) var color_shadow = Color(0,0,0,1)
export(float) var arrow_width = 0.25
export(Font) var normal_font
#export(Font) var bold_font
#export(Font) var italics_font
#export(Font) var bold_italics_font
#export(Font) var mono_font
export(NodePath) var lock_target = null
export(int) var words_per_minute = 200 # world median words readed by minute
export(bool) var auto_hide = true

export var show_debug_messages = false

var vertices = Array()
var colors = Array()
var vertices_shadow = Array()
var colors_shadow = Array() 
var uvs = Array()
var area = 0.0
var rad = 0.0
var font = Font.new()
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
		c = p
		if p=='Object':
			break
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
	var resolution = 48.0
	var a = (PI*2)/resolution
	var p = padding * font.get_string_size(" ").y
	vertices.clear()
	colors.clear()
	uvs.clear()
	#arrow_index = vertices.size()
	vertices.append( [Vector2(0,0),Vector2(0,0),Vector2(0,0)] )
	colors.append( [color_center,color,color] )
	uvs.append([Vector2(0,0),Vector2(0,0),Vector2(0,0)])
	var _rad = rad + padding
	for i in range(resolution):
		var x0 = cos(a*i)*_rad * _ratio.x
		var y0 = sin(a*i)*_rad * _ratio.y
		var x1 = cos((a*i)+a)*_rad * _ratio.x
		var y1 = sin((a*i)+a)*_rad * _ratio.y
		vertices.push_back( [Vector2(rad,0), Vector2(x0,y0), Vector2(x1,y1)] )
		colors.push_back( [color_center,color,color] )
		uvs.push_back([Vector2(0,0),Vector2(0,0),Vector2(0,0)])
	
	a = (PI*2)/resolution
	vertices_shadow.clear()
	colors_shadow.clear()
	vertices_shadow.append( [Vector2(0,0),Vector2(0,0),Vector2(0,0)] )
	colors_shadow.append( [color_shadow,color_shadow,color_shadow] )
	for i in range(resolution):
		var x0 = cos(a*i)*_rad * _ratio.x + cos(a*i) * shadown_width
		var y0 = sin(a*i)*_rad * _ratio.y + sin(a*i) * shadown_width
		var x1 = cos((a*i)+a)*_rad * _ratio.x + cos((a*i)+a) * shadown_width
		var y1 = sin((a*i)+a)*_rad * _ratio.y + sin((a*i)+a) * shadown_width
		vertices_shadow.push_back( [Vector2(0,0), Vector2(x0,y0), Vector2(x1,y1)] )
		colors_shadow.push_back( [color_shadow,color_shadow,color_shadow] )
	
	extra_offset = Vector2(_rad,_rad) * _ratio
	
	if not arrow_target:
		update()
	
	return words.size()

# a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V X Y Z
# Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
# But the Raven, sitting lonely on the placid bust, spoke only That one word, as if his soul in that one word he did outpour. Nothing farther then he uttered—not a feather then he fluttered—Till I scarcely more than muttered “Other friends have flown before—On the morrow he will leave me, as my Hopes have flown before.” Then the bird said “Nevermore.”

func _draw():
	var _ratio = Vector2(1.0/ratio, ratio)
	
	var _arrow_vertices = [Vector2(),Vector2(),Vector2()]
	var _arrow_colors = [color,color,color]
	var _arrow_vertices_shadow = [Vector2(),Vector2(),Vector2()]
	var _arrow_colors_shadow = [color_shadow,color_shadow,color_shadow]
	var _arrow_uvs = [Vector2(0,0),Vector2(0,0),Vector2(0,0)]
	
	# draw arrow
	var _t = _arrow_target
	if not arrow_target:
		_t = Vector2( 0,rad*1.45  * _ratio.y )
	var nor = _t.normalized()
	var per = Vector2(-nor.y,nor.x)
	_arrow_vertices[0] = _t
	_arrow_vertices[1] = per * rad * arrow_width*_ratio #Vector2( -rad*0.25, rad/2.0 ) * _ratio
	_arrow_vertices[2] = per * -rad * arrow_width*_ratio #Vector2( rad*0.25, rad/2.0 ) * _ratio
	_arrow_vertices_shadow[0] = _t + shadown_width * nor
	_arrow_vertices_shadow[1] = per * rad * arrow_width * _ratio + per * shadown_width*_ratio.x #Vector2( -rad*0.25 - shadown_width, rad/2.0 ) * _ratio
	_arrow_vertices_shadow[2] = per * -rad * arrow_width * _ratio - per * shadown_width*_ratio.x #Vector2( rad*-0.25 + shadown_width, rad/2.0 ) * _ratio
	
	# adjust to fit screen
	var _offset = Vector2()
	var left_top = rect_global_position - extra_offset
	var right_bottom = rect_global_position + extra_offset
	if left_top.x<0:
		_offset.x = 0.0 - left_top.x
	if left_top.y<0:
		_offset.y = 0.0 - left_top.y
	if right_bottom.x > get_viewport().get_visible_rect().size.x:
		_offset.x = -(right_bottom.x - get_viewport().get_visible_rect().size.x)
	if right_bottom.y > get_viewport().get_visible_rect().size.y:
		_offset.y = -(right_bottom.y - get_viewport().get_visible_rect().size.y)
	draw_set_transform(_offset, 0, Vector2(1,1))
	
	# shadow
	for i in range(vertices.size()):
		draw_primitive( vertices_shadow[i],colors_shadow[i],uvs[i],null )
	draw_primitive( _arrow_vertices_shadow, _arrow_colors_shadow, _arrow_uvs, null)
	
	# background
	for i in range(vertices.size()):
		draw_primitive( vertices[i],colors[i],uvs[i],null )
	draw_primitive( _arrow_vertices, _arrow_colors, _arrow_uvs, null)
	
	
	# text
	var y = globalY
	for l in lines:
		draw_string(font,Vector2(l[0],y),l[1], Color(0,0,0,1))
		y += l[2]
		

func _process(delta):
	if arrow_target:
		if _is3D:
			_arrow_target = get_viewport().get_camera().unproject_position(arrow_target.global_transform.origin) - get_global_transform().origin
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
	

func _ready():
	if not normal_font:
		normal_font = .get_font('font')
	#if not bold_font:
	#	bold_font = .get_font('font')
	#if not italics_font:
	#	italics_font = .get_font('font')
	#if not bold_italics_font:
	#	bold_italics_font = .get_font('font')
	#if not mono_font:
	#	mono_font = .get_font('font')
	
	# prevent wrong initialization
	set_process(false)
	
	# if lock target exist set arrow to it
	if lock_target:
		var obj = get_node(lock_target)
		if obj:
			target(obj)
	
	#rect_min_size = Vector2(500,500)
	if text and text.length()>0:
		say(text)
	else:
		hide()