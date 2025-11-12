extends GridContainer

@export var container_scene: PackedScene
@export var video_player: GalleryPlayer

func _ready():
	var vids = DirAccess.open("res://Videos/")
	for file in vids.get_files():
		if file.ends_with(".ogv"):
			var instance: GalleryVideoContainer = container_scene.instantiate()
			instance.video_name = file.replace(".ogv", "")
			instance.video_player = video_player
			add_child(instance)
