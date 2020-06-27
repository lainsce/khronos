namespace Khronos.FileManager {
        public MainWindow win;
        public File file;
        public string buffer_text;
        public void save_file (string path, string text) throws Error {
            try {
                GLib.FileUtils.set_contents (path, text);
            } catch (Error err) {
                print ("Error writing file: " + err.message);
            }
        }

        public void save_as (MainWindow win) throws Error {
            string buffer_text = "";
            debug ("Save as button pressed.");
            var file = Dialog.display_save_dialog ();

            try {
                debug ("Saving file…");
                if (file == null) {
                    debug ("User cancelled operation. Aborting.");
                } else {
                    if (win.is_modified == true) {
                        buffer_text += "task,time,startdate\n";
                        buffer_text += get_column_tasks (win.column);
                        var buffer = buffer_text;

                        if (!file.get_basename ().down ().has_suffix (".csv")) {
                            var file_final = File.new_for_path (file.get_path () + ".csv");
                            string file_path_final = file_final.get_path ();
                            save_file (file_path_final, buffer);
                        }
                        reset_modification_state (win);
                    }
                }
            } catch (Error e) {
                warning ("Unexpected error during save: " + e.message);
            }

            file = null;
        }

        public string get_column_tasks (DayColumn column) {
            string task_string = "";
            foreach (var task in column.get_tasks ()) {
                task_string += "\"" + task.name + "\",\"" + task.time + "\",\"" + task.date + "\"\n";
            }
            return task_string;
        }

        public void reset_modification_state (MainWindow win) {
            win.is_modified = false;
        }
}
