namespace Khronos.FileManager {
    public unowned MainWindow win = null;
    public async void save_as (MainWindow win) throws Error {
        string tasks = "";
        debug ("Save as button pressed.");
        var file = Dialog.display_save_dialog ();
        uint i, n = win.ls.get_n_items ();

        tasks += "task,timedate\n";
        for (i = 0; i < n; i++) {
            var item = win.ls.get_item (i);
            tasks += "\"" + ((Log)item).name + "\",\"" + ((Log)item).timedate + "\"\n";
        }

        if (!file.get_basename ().down ().has_suffix (".csv")) {
            var file_final = File.new_for_path (file.get_path () + ".csv");
            string file_path_final = file_final.get_path ();
            GLib.FileUtils.set_contents (file_path_final, tasks);
        }

        file = null;
    }
}
