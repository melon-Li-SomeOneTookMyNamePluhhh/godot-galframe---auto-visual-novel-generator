extends CanvasLayer
signal swap
var cg = "res://artResource/background/cg.txt"
var cg_all = FileAccess.open(cg, FileAccess.READ)
var save_path = "user://save/save_total.tres"
var start_location = "res://artResource/background/"
var cg_list = []
var cg_cover_list = []
# Called when the node enters the scene tree for the first time.


func _ready():
	$present_pic.visible = false
	$present_vid.visible = false
	while not cg_all.eof_reached():
		var line = Array(cg_all.get_line().rsplit(" "))
		print(line)
		cg_list.append(line.pop_front())
		cg_cover_list.append(line.pop_front())
	get_cover()
	for slot in $main/CenterContainer/GridContainer.get_children():
		slot.connect("view", present)


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _process(delta):
	if Input.is_action_just_pressed("return") and ($present_pic.visible or $present_vid.visible):
		$present_pic.texture = null
		$present_vid.stream = null
		$main.visible = true
		$present_pic.visible = false
		$present_vid.visible = false
	
	
func get_cover():
	for slot in $main/CenterContainer/GridContainer.get_children():
		if cg_cover_list.is_empty():
			return
		if not slot.has_cover:
			slot.load_cover(cg_cover_list.pop_front())
			slot.has_cover = true
			slot.cg = cg_list.pop_front()
	
	
func unlock(cg_name: String):
	for slot in $main/CenterContainer/GridContainer.get_children():
		if slot.cg == cg_name:
			slot.open()
			var save_file = ResourceLoader.load(save_path)
			if cg_name not in save_file.unlocked_cg:
				print("add new cg")
				save_file.unlocked_cg.append(cg_name)
				ResourceSaver.save(save_file, save_path)
	
	
func load_unlock():
	# 从存档中解锁CG
	print("unlocking cg")
	var saved_data = ResourceLoader.load(save_path)
	print(saved_data.unlocked_cg)
	for cg in saved_data.unlocked_cg:
		unlock(cg)
	
	
func present(CG_name: String):
	print("presenting")
	var file_at = quick_search(CG_name)
	if file_at == null:
		print("not here!")
		return
	if CG_name.substr(len(CG_name)-4, -1) == ".ogv":
		print("present vid")
		$present_vid.visible = true
		$present_vid.stream = ResourceLoader.load(file_at)
		$present_vid.play()
		$main.visible = false
	else:
		print("present pic")
		$present_pic.visible = true
		$present_pic.texture = ResourceLoader.load(file_at)
		$main.visible = false
	
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
		
func _on_return_pressed():
	self.visible = false
	emit_signal("swap")
