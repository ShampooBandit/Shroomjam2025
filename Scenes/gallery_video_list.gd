extends GridContainer

func _ready():
	var vids = DirAccess.open("res://Videos/")
	for file in vids.get_files():
		print(file)
