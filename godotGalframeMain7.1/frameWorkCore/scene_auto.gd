extends CanvasLayer
@onready var file_location = "res://dialogue/Start.txt"
@onready var file = FileAccess.open(file_location, FileAccess.READ)
@onready var choice_reach = false
@onready var auto_play = false
# 自动播放状态，在这个状态下点击不会触发台词展现和下一条台词的效果
@onready var speed_up = false
# 快进状态，在这个状态下点击不会触发台词展现和下一条台词的效果
@onready var UI_visible = true
# 对话框隐藏的话不会继续播放
@export var can_press = true
# 这个不要动，是用来在加载游戏时暂停操作的
@export var load_start = false
# 这个可以动，但动了影响性能
@export var auto_clear_bgm = false
@export var auto_clear_sound_effect = false
@export var auto_clear_voice = false
@onready var start_time = true #确保proceed只在需要的时候开始记时
# 在选项出现的情况下停止 proceed继续读取txt文档
@onready var speed_start_time = true
@onready var clear_avatar = true
# 每行文案出现角色立绘变动指令时自动清除所有角色立绘
var line_at = 0
# 记录台词行数
var dialogue
var character
var command
var loading = false
var option = preload("res://frameWorkCore/choice.tscn")
var save_path = "user://save/save_total.tres"
var state = []
var leave = false
# 用于暂时储存快进和自动播放的状态，以便在CG展示结束后继续
var bgmlist = []


func _ready():
	$"DO NOT TOUCH/Panel".visible = false
	%dialogue.text = ""
	%character.text = ""
	%dialogue.visible_ratio = 0.0
	%errorlog.text = ""
	$UI.connect("on_button",_on_button)
	$UI.connect("out_button", _out_button)
	_proceed()
	# 这次proceed 只会搭建背景和角色
	set_bus()
	load_setting()
	self.get_tree().call_group("main", "game_created")
	# 告诉main游戏已经创建完毕
	
	
func set_bus():
	# 将所有音频设置到对应的管线
	for bgm in self.find_child("music").find_child("bgm").get_children():
		bgm.set_bus("bgm")
	for voice in self.find_child("music").find_child("voice").get_children():
		voice.set_bus("voice")
	for sfx in self.find_child("music").find_child("sound_effect").get_children():
		sfx.set_bus("sound_effect")
		
		
func _process(_delta):
	if Input.is_action_just_pressed("press") and can_press:
		$dialogue.visible = true
		$UI.visible = true
		$choice.visible = true
		if can_press:
			if auto_play:
				auto_play = false
				return
			if speed_up:
				speed_up = false
				return
			if not UI_visible:
				UI_visible = true
				return
			# 如果在自动播放状态下不能通过点击调整台词
			# UI隐藏状态也不行
			# 通过点击取消UI隐藏和自动播放状态
			# 在CG展示模式下直接锁死
			if %dialogue.visible_ratio != 1.0:
				%dialogue.visible_ratio = 1.0
				# 双击显示全部台词
			else:
				if not choice_reach:
					%dialogue.visible_ratio = 0.0 
				_proceed()
	if Input.is_action_just_pressed("auto"):
		_on_auto_pressed()
	if speed_up and speed_start_time:
		speed_start_time = false
		$speed_up_timer.start()
	if auto_play and %dialogue.visible_ratio == 1.0 and start_time:
		start_time = false
		$auto_play_timer.start()
		# 如果处于自动播放状态，且台词已播放至结尾。那么开始跳到下一台词的倒计时
# 展示台词和角色名


func _proceed():
	if choice_reach:
		return
	line_at += 1
	clear_avatar = true
	var text = file.get_line()
	if file.eof_reached():
		leave = true
		_on_leave_pressed()
	if text == "choice":
		$dialogue.visible = true
		$UI.visible = true
		%dialogue.visible_ratio = 1.0
		choice_reach = true
		_choice_jump()
		file.close()
	else:
		if speed_up:
			%dialogue.visible_ratio = 1.0
		else:
			%dialogue.visible_ratio = 0.0
		text = text.replace("：", ":")
		character = text.substr(0, text.find(":")+1)
		if character == " command:" or character == ":":
			character = ""
		if text.find(" command:") != -1:
			dialogue = text.substr(text.find(":") + 1, text.find(" command:") - text.find(":"))
		else:
			dialogue = text.substr(text.find(":") + 1, text.find(" command:"))
		if character == "":
			$dialogue/dialogue_box.visible = false
			%dialogue.narrration = true
		else:
			$dialogue/dialogue_box.visible = true
			%dialogue.narrration = false
		dialogue = dialogue.replace("\\command:", "command:")
		command = text.substr(text.find(" command:"))
		%dialogue.text = dialogue
		self.get_tree().call_group("dialogue", "_start_dialogue")
		%character.text = character
		_command_execute(command)
# 读取命令并执行	


func _command_execute(commands: String):
	var format = RegEx.new()
	format.compile("[(][^)]*[)]")
	var order_list = []
	for order in format.search_all(commands):
		order_list.append(order.get_string().substr(1).left(-1))
	for orders in order_list:
		var order_mod = Array(orders.replace(" ", "").rsplit(","))
		var which_order = order_mod.pop_front()
		if which_order == "character":
			if clear_avatar:
				$background/left/character.texture = null
				$background/right/character.texture = null
				$background/mid/character.texture = null
				clear_avatar = false
			if order_mod.size() == 3:
				_change_avatar(order_mod.pop_front(), order_mod.pop_front(), order_mod.pop_front())
			elif order_mod.size() == 2:
				_change_avatar(order_mod.pop_front(), order_mod.pop_front())
			else:
				_change_avatar(order_mod.pop_front())
		elif which_order == "background":
			if order_mod.size() == 2:
				_change_avatar(order_mod.pop_front(), order_mod.pop_front())
			else:
				_change_background(order_mod.pop_front())
		elif which_order == "bgm" or which_order == "sound_effect" or which_order == "voice":
			change_music(which_order, order_mod.pop_front())
		elif which_order == "CG":
			display_CG(order_mod.pop_front())
			
			
func change_music(type: String, which: String):
	if which == "clear":
		music_clear(type)
		return
	if auto_clear_bgm:
		music_clear("bgm")
	if auto_clear_sound_effect:
		music_clear("sound_effect")
	if auto_clear_voice:
		music_clear("voice")
	if type == "bgm" and which in bgmlist:
		return
		# 如果当前某个BGM已经在播放，则不再重复播放
		# 这个是为了修复加载存档时无法加载音乐导致的，但没做好
	if type == "bgm":
		# 将bgm添加到播放缓存中
		bgmlist.append(which)
	if loading:
		# 如果游戏正在加载中，不播放音乐
		return
	for slot in self.find_child("music").find_child(type).get_children():
		if slot.stream == null:
			var music_at = search_path(which)
			if music_at != null:
				slot.stream = ResourceLoader.load(music_at)
				slot.playing = true
			else:
				$"DO NOT TOUCH/Panel".visible = true
				%errorlog.text = "错误：未找到对应音频，请确保音频素材位于\"music\"文件夹下且后缀正确(.mp3, .wav)"
			return
	$"DO NOT TOUCH/Panel".visible = true
	%errorlog.text = "错误：音频素材对应的音频类型槽位不足，请参考教程并复制粘贴对应音频槽位下的音乐节点"
	
	
func music_clear(type: String):
	bgmlist = []
	for slot in self.find_child("music").find_child(type).get_children():
		slot.playing = false
		slot.stream = null
	
		
func _change_avatar(avatar: String, position = "mid", slot = "character"):
	if avatar == "clear":
		$background/left/character.texture = null
		$background/right/character.texture = null
		$background/mid/character.texture = null
		return
	var start_location = "res://artResource/character/"
	var avatar_at = search_path(avatar)
	if avatar_at == null:
		$"DO NOT TOUCH/Panel".visible = true
		%errorlog.text = "错误：未找到对应角色,请检查角色图像是否位于\"character\"文件夹下以及图片后缀(.jpg, .png) 是否对应"
		return
	%background.find_child(position).find_child(slot).texture = ResourceLoader.load(avatar_at)
	
	
func _change_background(background: String, loop = "True"):
	self.get_tree().call_group("CG", "unlock", background)
	var start_location = "res://artResource/background/"
	var background_at =search_path(background)
	if background_at == null:
		$"DO NOT TOUCH/Panel".visible = true
		%errorlog.text = "错误：未找到对应背景,请检查角色图像是否位于\"background\"文件夹下以及图片后缀(.jpg, .png) 是否对应"
		return
	if background.substr(len(background)-4, -1) == ".ogv":
		# 识别是否是ogv格式
		if loop == "False":
			$background/viedo_background.loop = false
		else:
			$background/viedo_background.loop = true
		$background/viedo_background.stream = ResourceLoader.load(background_at)
		$background/viedo_background.play()
	else:
		$background/background.texture = ResourceLoader.load(background_at)
		$background/viedo_background.stream = null

func display_CG(CG: String):
	if loading:
		return
	state = [auto_play, speed_up]
	speed_up = false
	auto_play = false
	$UI.visible = false
	$dialogue.visible = false
	can_press = false
	_change_background(CG, "False")
	

	
# 读取选项并跳转
func _choice_jump():
	var choice_list = []
	while not file.eof_reached():
		var choice = file.get_line()
		if choice != "":
			choice_list.append(choice)
		# 将所有的选项都放进一个列表里
	if "" in choice_list:
		# 检查空白选项是否出现
		$"DO NOT TOUCH/Panel".visible = true
		%errorlog.text = "错误： 有空白选项，这个错误不应该出现的。你是不是在酒吧点炒饭了"
	else:
		for choice in choice_list:
			var ready_option = option.instantiate()
			%choice_box.add_child(ready_option)
			var choice_text = ready_option.get_node("center").get_node("choice_text")
			var going_to = ready_option.get_node("going_to")
			choice_text.text = choice.substr(0, choice.rfind(" "))
			going_to.text = choice.substr(choice.rfind(" ") + 1)
			ready_option.connect("travel_to", _travel)
			
			
func _travel(location: String):
	# 根据txt文件名找到文件路径并跳转到该文件
	var new_path = file_location.substr(0, file_location.rfind(file_location.get_file()))
	# 切掉原txt文件路径中的txt文件并搜索该txt所在的文件夹及其附属文件夹
	if load_start:
		new_path = "res://dialogue/"
	for child in %choice_box.get_children():
		%choice_box.remove_child(child)
	if search_path(location) != null:
		file_location = search_path(location)
		file.close()
		file = FileAccess.open(file_location, FileAccess.READ)
		choice_reach = false
		%dialogue.visible_ratio = 0
		line_at = 0
		_proceed()
	else:
		$"DO NOT TOUCH/Panel".visible = true
		%errorlog.text = "错误： 未找到可跳转文件，请确保txt文件在\"dialogue\"文件夹下且使用英文输入法输入txt (.txt 而不是 。txt)"


#func _helper_search_file(directory: String, files: String):
	# recursion helper
	# 智力巅峰, 然而崩了一次，BUG还复现不出来。
	#var direction = DirAccess.open(directory)
	#if files not in direction.get_files() and direction.get_directories().is_empty():
		#return null
	#if files in DirAccess.open(directory).get_files():
		#return directory + "/" + files
	#else:
		#for path in DirAccess.open(directory).get_directories():
			#if _helper_search_file(directory +"/" + path+ "/", files) != null:
				#return _helper_search_file(directory +"/" + path, files)
		#return null
		
func search_path(filename: String):
	var map = ResourceLoader.load("res://save/mapper_total.tres")
	return map.search_path(filename)
	
		
func _on_save_pressed():
	var temp_screen = get_viewport().get_texture().get_image()
	get_tree().call_group("main", "display_save")
	get_tree().call_group("save", "image_here", temp_screen)
	for canvas in self.get_children():
		if canvas is CanvasLayer:
			canvas.visible = false
	self.set_process(false)
	
	
func _on_load_pressed():
	get_tree().call_group("main", "display_load")
	for canvas in self.get_children():
		if canvas is CanvasLayer:
			canvas.visible = false
	self.set_process(false)
	
	
func _on_quicksave_pressed():
	var progress = progress_data.new()
	progress.which_file = file_location.get_file()
	progress.which_line = line_at
	ResourceSaver.save(progress, "user://save/quick_save.tres")
	
	
func _on_quickload_pressed():
	var quick_save = "user://save/quick_save.tres"
	var find_save = ResourceLoader.load(quick_save)
	if find_save == null:
		return
	print(find_save)
	self.load_progress(find_save.which_file, find_save.which_line)


func _on_setting_pressed():
	get_tree().call_group("main", "display_setting")
	for canvas in self.get_children():
		if canvas is CanvasLayer:
			canvas.visible = false
	self.set_process(false)
	
	
func _on_review_pressed():
	pass # Replace with function body.
	# 还没做
	
	
func _on_show_tree_pressed():
	pass # Replace with function body.
	# 还没做
	
	
func _on_auto_pressed():
	if auto_play:
		%dialogue.on_auto = false
		auto_play = false
		return
		# 如果已经在自动播放则取消自动播放
	speed_up = false
	auto_play = true
	%dialogue.on_auto = true
	_proceed()
	
	
func _on_forward_speed_pressed():
	if speed_up:
		speed_up = false
		return
	auto_play = false
	speed_up = true
	_proceed()
	
	
func _on_forward_to_next_choice_pressed():
	if choice_reach:
		return
	while not choice_reach and not leave:
		_proceed()
	# 先这样, 之后改
	
	
func _on_visible_pressed():
	if $dialogue.visible and $UI.visible and $choice.visible:
		$dialogue.visible = false
		$UI.visible = false
		$choice.visible = false
		UI_visible = false
		auto_play = false
	else:
		$dialogue.visible = true
		$UI.visible = true
		$choice.visible = true
		# 这段可能不用, 但留着保险
		
		
func _on_leave_pressed():
	get_tree().call_group("main", "back_menu")
	
func load_progress(which_file: String, which_line: int):
	music_clear("bgm")
	music_clear("voice")
	music_clear("sound_effect")
	_change_avatar("clear")
	loading = true
	file_location = "res://dialogue/Start.txt"
	_travel(which_file)
	while which_line != line_at:
		_proceed()
	self.get_tree().call_group("main", "game_created")
	# 第二次告诉main游戏已经创建，这代表即将播放动画fade_out
	loading = false
	var musics = []
	while not bgmlist.is_empty():
		musics.append(bgmlist.pop_back())
	for music in musics:
		change_music("bgm", music)
	_command_execute(command)
	
	
func load_setting():
	print("load setting!")
	var save = ResourceLoader.load(save_path)
	print(save.get_type())
	print(save.dialogue_box_transparency)
	$dialogue/dialogue_box.modulate.a = save.dialogue_box_transparency / 100
	$dialogue/narration_box.modulate.a = save.dialogue_box_transparency / 100
	$UI/Control/ColorRect.color = save.windows_color	
# no need to care for the rest it is what it is


func _on_button():
	can_press = false
	
func _out_button():
	can_press = true
	
func _transition_done():
	self.get_tree().call_group("dialogue", "_start_dialogue")	
	
func get_progress(slots: int):
	self.get_tree().call_group("save", "save_progress", file_location.get_file(), slots, line_at)

func _on_auto_play_timer_timeout():
	start_time = true
	if auto_play:
		# 倒计时结束开始展示下一条台词
		_proceed()

func _on_speed_up_timer_timeout():
	speed_start_time = true
	if speed_up:
		_proceed()


func _on_viedo_background_finished():
	if $background/viedo_background.loop:
		# 如果处于循环状态，说明正在展示动态背景，那么不管
		return
	# 不然就说明CG展示结束了，下一行台词了该
	$UI.visible = true
	$dialogue.visible = true
	can_press = true
	auto_play = state.pop_front()
	speed_up = state.pop_front()
	_proceed()
