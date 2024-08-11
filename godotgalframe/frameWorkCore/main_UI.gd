extends CanvasLayer
signal on_button
signal out_button
var play_speed = 0.1
# Called when the node enters the scene tree for the first time.
func _ready():
	%function_name.text = ""
	for nodes in $Control/VBoxContainer.get_children():
		nodes.mouse_exited.connect(_mouse_leave)
	$Control/volumn_slider.visible = false
	$Control/volumn_slider.editable = false
		
func _mouse_leave():
	%function_name.text = ""
	emit_signal("out_button")

func reach_button():
	emit_signal("on_button")
	
func _on_save_mouse_entered():
	%function_name.text = "保存"
	reach_button()

func _on_load_mouse_entered():
	%function_name.text = "加载"
	reach_button()
	
func _on_quicksave_mouse_entered():
	%function_name.text = "快速保存"
	reach_button()
	
func _on_quickload_mouse_entered():
	%function_name.text = "快速加载"
	reach_button()
	
func _on_setting_mouse_entered():
	%function_name.text = "设置"
	reach_button()
	
func _on_volumn_mouse_entered():
	%function_name.text = "音量"
	reach_button()
	
func _on_back_to_last_choice_mouse_entered():
	%function_name.text = "展示剧情树"
	reach_button()


func _on_back_by_one_script_mouse_entered():
	%function_name.text = "历史记录"
	reach_button()
	
func _on_auto_mouse_entered():
	%function_name.text = "自动播放"
	reach_button()
	
func _on_forward_speed_mouse_entered():
	%function_name.text = "快进"
	reach_button()
	
func _on_forward_to_next_choice_mouse_entered():
	%function_name.text = "快进到下一选项"
	reach_button()
	
func _on_visible_mouse_entered():
	%function_name.text = "隐藏对话框"
	reach_button()

func _on_leave_mouse_entered():
	%function_name.text = "回到主菜单"
	reach_button()


func _on_volumn_pressed():
	$Control/volumn_slider.visible = true
	$Control/volumn_slider.editable = true
	



func _on_volumn_slider_value_changed(value):
	var setting = ResourceLoader.load("user://save/save_total.tres")
	setting.total_volumn = $Control/volumn_slider.value
	ResourceSaver.save(setting, "user://save/save_total.tres")
