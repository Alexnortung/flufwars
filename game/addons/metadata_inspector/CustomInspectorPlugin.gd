extends EditorInspectorPlugin

var someobject = null

# this faux EditorInspectorPlugin is necessary to update the real EditorPlugin at the right time
func can_handle(object):
	
#	if object.is_class("ScriptEditorDebuggerInspectedObject"):
#		print(object.get_remote_object_id())

	if object is Node:
		someobject = object
		var metadata_inspector = get_metadata_inspector(object)
		if object.get_filename().length() > 0 and object.get_filename() != object.get_tree().edited_scene_root.filename:
			metadata_inspector.set_nonodelabel("Please edit the metadata from inside the scene of this instance.")
		else:
			metadata_inspector.update_node(object, ["load"], {}, [["^^***-****-- NO DEFAULT FOCUS --****-***^^"], "new"])
	else:
		if is_instance_valid(someobject):
			var metadata_inspector = get_metadata_inspector(someobject)
			metadata_inspector.set_nonodelabel("Select a single node to edit and view its metadata.")
	return false

func get_metadata_inspector(object):
	for n0 in object.get_tree().get_root().get_children():
		for n1 in n0.get_children():
			if n1.is_class("EditorPlugin"):
				if "is_metadata_inspector" in n1:
					return(n1)
