namespace Khronos.FileManager {
    public async void save_as (ListStore ls) throws Error {
        string tasks = "";
        var file = yield Dialog.display_save_dialog ();
        uint i, n = ls.get_n_items ();

        tasks += "task,timedate\n";
        for (i = 0; i < n; i++) {
            var item = ls.get_item (i);
            tasks += "\"" + ((Log)item).name.replace("\"", "") +
            "\",\"" + ((Log)item).timedate.replace("\"", "")
                                          .replace("<span font_features='tnum'>", "")
                                          .replace("</span>", "")
                                          .replace("∶", ":") + "\"\n";
        }

        if (!file.get_basename ().down ().has_suffix (".csv")) {
            GLib.FileUtils.set_contents (file.get_path() + ".csv", tasks);
        } else {
            GLib.FileUtils.set_contents (file.get_path(), tasks);
        }

        debug ("Save as button pressed.");
    }
}
