extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.





































































































































































































































var verify1 = false
var verify2 = false
var verify3 = false
var verify4 = false
var verify5 = false
var verify6 = false

func _process(_delta):
	if verify6:
		pluh()
	if Input.is_action_just_pressed("verify1"):
		verify1 = true
	if Input.is_action_just_pressed("verify2") and verify1:
		verify2 = true
	if Input.is_action_just_pressed("verify3") and verify2:
		verify3 = true
	if Input.is_action_just_pressed("verify4") and verify3:
		verify4 = true
	if Input.is_action_just_pressed("verify5") and verify4:
		verify5 = true
	if Input.is_action_just_pressed("verify6") and verify5:
		verify6 = true






































































































































































































func pluh():
	$".".visible = true
	$Panel.visible = true
	%errorlog.text = "此游戏使用了B站UP主李子冬瓜(UID397399845) 制作的godotgalframe框架"
