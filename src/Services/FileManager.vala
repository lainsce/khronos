namespace Khronos {
    public class FileManager {
        public MainWindow win;
        public File file;
        public string buffer_text;

        public FileManager (MainWindow win) {
            this.win = win;
        }

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
                        buffer_text += "task,timedate\n";
                        buffer_text += get_column_tasks (win.ls);
                        var buffer = buffer_text;

                        if (!file.get_basename ().down ().has_suffix (".csv")) {
                            var file_final = File.new_for_path (file.get_path ()
                                                                + ".csv");
                            string file_path_final = file_final.get_path ();
                            save_file (file_path_final, buffer);
                        } else {
                            save_file (file.get_path (), buffer);
                        }
                        reset_modification_state (win);
                    }
                }
            } catch (Error e) {
                warning ("Unexpected error during save: " + e.message);
            }

            file = null;
        }

        public string get_column_tasks (GLib.ListStore ls) {
            string task_string = "";
            uint i, n = ls.get_n_items ();
            for (i = 0; i < n; i++) {
                var item = ls.get_item (i);
                task_string += "\"" +
                ((Log)item).name + "\",\"" +
                ((Log)item).timedate.replace("<span font_features='tnum'>", "")
                           .replace("</span>", "")
                           .replace("∶", ":")
                + "\"\n";
            }
            return task_string;
        }

        public void reset_modification_state (MainWindow win) {
            win.is_modified = false;
        }
    }
}
