extends Resource
class_name Gamedata
@export var play_speed = 20.0
@export var auto_play_speed = 20
@export var red = 140.0
@export var green = 140.0
@export var blue = 140.0
@export var alpha = 70
@export var windows_color = Color(red/255,green/255,blue/255,alpha/100)
@export var total_volumn = 1.0
@export var bgm_volumn = 1.0
@export var voice_volumn = 1.0
@export var sfx_volumn = 1.0
@export var dialogue_box_transparency = 100.0
@export var saved_game = {"quick_save": null, "0": null, "1": null, "2": null, "3": null, 
"4": null, "5":null, "6":null, "7":null, "8": null, "9": null, "10": null, "11": null, "12": null, 
"13":null, "14":null, "15":null, "16":null, "17":null, "18":null, "19":null}
# saved_game 可能用不上 先留着
	
	
func reset_all():
	play_speed = 20.0
	auto_play_speed = 20
	red = 140.0
	green = 140.0
	blue = 140.0
	alpha = 1.0
	windows_color = Color(red,green,blue,alpha)
	total_volumn = 1.0
	bgm_volumn = 1.0
	voice_volumn = 1.0
	sfx_volumn = 1.0
	dialogue_box_transparency = 1.0
	
	
func reset_setting_display():
	windows_color = Color(140.0,140.0,140.0,200)

func reset_setting():
	play_speed = 10.0
	
func calc_play_speed(progress: float):
	play_speed = (20.0 / 50) * progress
	
func calc_auto_play_speed(progress: float):
	auto_play_speed = (20.0 / 50) * progress
	
func change_red(progress: float):
	red = progress
	windows_color = Color(red/255,green/255,blue/255,alpha/100)
	
func change_blue(progress: float):
	blue = progress
	windows_color = Color(red/255,green/255,blue/255,alpha/100)
	
func change_green(progress: float):
	green = progress
	windows_color = Color(red/255,green/255,blue/255,alpha/100)

func change_alpha(progress: float):
	alpha = progress
	windows_color = Color(red/255,green/255,blue/255,alpha/100)
	

	
	
	
