namespace Khronos.FileManager {
    public async void save_as (ListStore ls) throws Error {
        string tasks = "";
        debug ("Save as button pressed.");
        var file = yield Dialog.display_save_dialog ();
        uint i, n = ls.get_n_items ();

        tasks += "task,timedate\n";
        for (i = 0; i < n; i++) {
            var item = ls.get_item (i);
            var name = ((Log)item).name;
            var timedate = ((Log)item).timedate.replace ("<span font_features='tnum'>", "").replace("</span>", "").replace("∶", ":");
            tasks += "\"" + name + "\",\"" + timedate + "\"\n";
        }

        if (!file.get_basename ().down ().has_suffix (".csv")) {
            var file_final = File.new_for_path (file.get_path () + ".csv");
            try {
                if (file_final.query_exists ()) {
                    file_final.delete ();
                }
                var file_stream = file_final.create (FileCreateFlags.REPLACE_DESTINATION);
                var data_stream = new DataOutputStream (file_stream);
                data_stream.put_string(tasks);
            } catch (Error e) {
                warning ("Failed to save: %s\n", e.message);
            }
        } else {
            try {
                if (file.query_exists ()) {
                    file.delete ();
                }
                var file_stream = file.create (FileCreateFlags.REPLACE_DESTINATION);
                var data_stream = new DataOutputStream (file_stream);
                data_stream.put_string(tasks);
            } catch (Error e) {
                warning ("Failed to save: %s\n", e.message);
            }
        }

        yield;
    }
}
