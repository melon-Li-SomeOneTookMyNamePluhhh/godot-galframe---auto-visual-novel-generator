extends TextureButton
@export var cg = ""
@export var lock = true
@export var has_cover = false
var start_location = "res://artResource/background/"
signal view
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func load_cover(cover: String):
	var file_at = quick_search(cover)
	if file_at == null:
		print("not here!")
		return
	print(file_at)
	$font_display.texture = ResourceLoader.load(file_at)
	
func open():
	lock = false
	$layer.visible = false


func store_CG(CG_name: String):
	var cg = CG_name


#func helper_search_file(directory: String, files: String):
	# recursion helper
	# 智力巅峰, 然而崩了一次，BUG还复现不出来。
	#var direction = DirAccess.open(directory)
	#if files not in direction.get_files() and direction.get_directories().is_empty():
		#return null
	#if files in DirAccess.open(directory).get_files():
		#return directory + "/" + files
	#else:
		#for path in DirAccess.open(directory).get_directories():
			#if helper_search_file(directory +"/" + path+ "/", files) != null:
				#return helper_search_file(directory +"/" + path, files)
		#return null	

func quick_search(filename: String):
	var map = ResourceLoader.load("res://save/mapper_total.tres")
	return map.search_path(filename)


func _on_pressed():
	if has_cover and not lock:
		emit_signal("view", cg)
