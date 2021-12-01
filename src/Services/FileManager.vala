namespace Khronos.FileManager {

    public async void save_logs (LogViewModel view_model) throws Error {
        debug ("Save as button pressed.");
        string tasks = "";
        var file = yield Dialog.display_save_dialog ();
        uint i, n = view_model.logs.get_n_items ();

        tasks += "task,timedate\n";
        for (i = 0; i < n; i++) {
            var item = view_model.logs.get_item (i);
            tasks += "\"" + ((Log)item).name.replace("\"", "") +
            "\",\"" + ((Log)item).timedate.replace("\"", "") + "\"\n";
        }

        GLib.FileUtils.set_contents (file.get_path(), tasks);
    }

    public async Gee.ArrayList<Log> load_as () throws Error {
        debug ("Open button pressed.");
        var file = yield Dialog.display_open_dialog ();
        string file_path = file.get_path ();
        string text;
        try {
            GLib.FileUtils.get_contents (file_path, out text);
        } catch (Error err) {
            print (err.message);
        }

        var logs = new Gee.ArrayList<Log> ();
        Log? current_log = null;

        int i = 0;
        string[] tokens = text.split ("\n");
        foreach (string line in tokens) {
            line = line.strip ();
            if (line.has_prefix ("\"")) {
                GLib.DateTime dt = new GLib.DateTime.now_local ();
                string[] logged = line.replace ("\"", "").strip ().split(",");
                print("%s\n".printf(logged[0]));
                print("%s\n".printf(logged[1]));

                current_log = new Log ();
                current_log.name = logged[0];
                current_log.timedate = "%s\n%s – %s".printf(logged[1],
                                                   ("%s").printf (dt.format ("%a, %d/%m %H∶%M∶%S")),
                                                   ("%s").printf (dt.add_full (0,
                                                                               0,
                                                                               0,
                                                                               ((int)logged[1].substring(0,1)),
                                                                               ((int)logged[1].substring(3,4)),
                                                                               ((int)logged[1].substring(6,7))).format ("%H∶%M∶%S")));


                logs.add (current_log);
            }

            i++;
        }

        return logs;
    }
}
