@tool
extends EditorPlugin

var run_button:MenuButton

var filesys:EditorFileSystemDirectory
var all_dirs:Array[EditorFileSystemDirectory]

var editorscript_filepath:Array[String]
var editorscript_name:Array[String]


## adds the button to the editor, connects needed signals to functions
func _ready()->void:
	if run_button:
		return
	run_button=MenuButton.new()
	run_button.flat=true
	run_button.text="Run"
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR,run_button)
	run_button.connect("about_to_popup",get_editor_scripts)
	run_button.get_popup().connect("index_pressed",run_editor_script)
	

		
## recursive get directories function
func get_all_dirs(filesystem:EditorFileSystemDirectory)->Array[EditorFileSystemDirectory]:
	var all_directories:Array[EditorFileSystemDirectory] = []
	all_directories.append(filesystem)
	for x:int in filesystem.get_subdir_count():
		all_directories.append(filesystem.get_subdir(x))
		for nested_dir:EditorFileSystemDirectory in get_all_dirs(filesystem.get_subdir(x)):
			all_directories.append(nested_dir)
	return all_directories


## gets all instances of your EditorScripts in your project directory, and adds them to two lookup arrays:
##  one for the EditorScripts name, and the other for its absolute proejct path.
func get_editor_scripts()->void:
	editorscript_filepath.clear()
	editorscript_name.clear()
	run_button.get_popup().clear()
	filesys=EditorInterface.get_resource_filesystem().get_filesystem()
	all_dirs=get_all_dirs(filesys)
	for index:int in all_dirs.size():
		for file_index in all_dirs[index].get_file_count():
			if all_dirs[index].get_file_script_class_extends(file_index)=="EditorScript"\
			and not editorscript_name.has(all_dirs[index].get_file(file_index)):
				editorscript_filepath.append(all_dirs[index].get_file_path(file_index))
				editorscript_name.append(all_dirs[index].get_file(file_index))
	if editorscript_name.size()>0 and run_button!=null:
		for x:String in editorscript_name:
			run_button.get_popup().add_item(x)
	
	
## when you select an option on the PopupMenu, runs the selected script, by index.
func run_editor_script(index:int)->void:
	if editorscript_filepath.size()>0:
		var script:Resource=load(editorscript_filepath[index])
		var this_script=script.new()
		this_script._run()
