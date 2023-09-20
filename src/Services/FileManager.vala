namespace Khronos.FileManager {
    public async void save_logs (LogViewModel view_model) throws Error {
        debug ("Save as button pressed.");
        string tasks = "";
        var file = yield Dialog.display_save_dialog ();
        uint i, n = view_model.logs.get_n_items ();

        tasks += "task,timedate,tags\n";
        for (i = 0; i < n; i++) {
            var item = view_model.logs.get_item (i);
            tasks += "\"" + ((Log)item).name.replace ("\"", "") +
            "\",\"" + ((Log)item).timedate.replace ("\"", "").replace ("\n", "") +
            "\",\"" + ((Log)item).tags + "\"\n";
        }

        GLib.FileUtils.set_contents (file.get_path (), tasks);
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
                string[] logged = line.replace ("\"", "").strip ().split (",");

                GLib.DateTime taskdt = new GLib.DateTime.local (dt.get_year (),
                                                  int.parse (logged[2].substring (1, 2)),
                                                  int.parse (logged[2].substring (4, 2)),
                                                  int.parse (logged[2].substring (7, 2)),
                                                  int.parse (logged[2].substring (12, 2)),
                                                  double.parse (logged[2].substring (17, 2)));

                current_log = new Log ();
                current_log.name = logged[0];
                current_log.timedate = "%s\n%s – %s".printf (logged[1].substring(0, 12),
                                                   ("%s").printf (logged[1].substring (13, 3) + ", " + logged[2].substring (0, 20)),
                                                   ("%s").printf (taskdt.add_full (dt.get_year (),
                                                                                   int.parse (logged[2].substring (1, 2)),
                                                                                   int.parse (logged[2].substring (4, 2)),
                                                                                   int.parse (logged[1].substring (1, 2)),
                                                                                   int.parse (logged[1].substring (5, 2)),
                                                                                   double.parse (logged[1].substring (10, 2))).format ("%H∶%M∶%S")));

                current_log.tags = logged[3];
                logs.add (current_log);
            }

            i++;
        }

        return logs;
    }
}
