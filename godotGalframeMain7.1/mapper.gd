extends Node
var save_path = "res://save/"
var save_file = "mapper_total.tres"
var res_background = "res://artResource/background/"
var res_character = "res://artResource/character/"
var res_music = "res://music/"
var res_dialogue = "res://dialogue/"
# Called when the node enters the scene tree for the first time.


func _ready():
	if not DirAccess.dir_exists_absolute(save_path):
		DirAccess.make_dir_absolute(save_path)
	var compile_data = Assetpath.new()
	ResourceSaver.save(compile_data, save_path + save_file)
	find_all_file(res_background)
	find_all_file(res_character)
	find_all_file(res_music)
	find_all_file(res_dialogue)
	print("COMPILE COMPLETE")
	var mapper = ResourceLoader.load("res://save/mapper_total.tres")
# Called every frame. 'delta' is the elapsed time since the previous frame.


func find_all_file(dir: String):
	var files = DirAccess.open(dir)
	for file in files.get_files():
		var location = helper_search_file(dir, file)
		var mapper = ResourceLoader.load("res://save/mapper_total.tres")
		mapper.add_path(file, location)
		print("mapped ", file, " to location ", location)
		ResourceSaver.save(mapper, "res://save/mapper_total.tres")
	for directories in files.get_directories():
		find_all_file(dir + "/" + directories)

func helper_search_file(directory: String, files: String):
	# recursion helper
	# 智力巅峰, 然而崩了一次，BUG还复现不出来。
	var direction = DirAccess.open(directory)
	if files not in direction.get_files() and direction.get_directories().is_empty():
		return null
	if files in DirAccess.open(directory).get_files():
		return directory + "/" + files
	else:
		for path in DirAccess.open(directory).get_directories():
			if helper_search_file(directory +"/" + path+ "/", files) != null:
				return helper_search_file(directory +"/" + path, files)
		return null
