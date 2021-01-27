namespace Khronos.FileManager {
    public async void save_as (ListStore ls) throws Error {
        string tasks = "";
        var file = yield Dialog.display_save_dialog ();
        uint i, n = ls.get_n_items ();

        tasks += "task,timedate\n";
        for (i = 0; i < n; i++) {
            var item = ls.get_item (i);
            tasks += "\"" + ((Log)item).name + "\",\"" + ((Log)item).timedate + "\"\n";
        }

        if (!file.get_basename ().down ().has_suffix (".csv")) {
            var file_final = File.new_for_path (file.get_path () + ".csv");
            string file_path_final = file_final.get_path ();
            GLib.FileUtils.set_contents (file_path_final, tasks);
        } else {
            GLib.FileUtils.set_contents (file.get_path(), tasks);
        }

        file = null;
        debug ("Save as button pressed.");
    }
}
