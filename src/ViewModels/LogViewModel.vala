/*
* Copyright (C) 2017-2022 Lains
*
* This program is free software; you can redistribute it &&/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/
public class Khronos.LogViewModel : Object {
    uint timeout_id = 0;
    public ObservableList<Log> logs { get; default = new ObservableList<Log> (); }
    public LogRepository? repository { private get; construct; }

    public LogViewModel (LogRepository repository) {
        Object (repository: repository);
    }

    construct {
        populate_logs.begin ();
    }

    public void create_new_log (Log? log) {
        logs.add (log);
        repository.insert_log (log);
        save_logs ();
    }

    public void update_log (Log log) {
        repository.update_log (log);
        save_logs ();
    }

    public void delete_log (Log log) {
        logs.remove (log);
        repository.delete_log (log.id);
        save_logs ();
    }

    public async void delete_trash (MainWindow win) {
        var dialog = new Adw.MessageDialog (win, _("Clear Logs?"), null);
        dialog.set_body (_("Clearing means the logs here will be permanently lost with no recovery."));
        dialog.add_response ("cancel", _("Cancel"));
        dialog.add_response ("clear",  _("Clear"));
        dialog.set_response_appearance ("clear", Adw.ResponseAppearance.DESTRUCTIVE);
        dialog.set_default_response ("clear");
        dialog.set_close_response ("cancel");
        dialog.response.connect ((response) => {
            switch (response) {
                case "clear":
                    depopulate_trashs.begin ();
                    dialog.close ();
                    break;
                case "cancel":
                default:
                    dialog.close ();
                    return;
            }
        });
        dialog.present ();
    }

    async void populate_logs () {
        var logs = yield repository.get_logs ();
        this.logs.add_all (logs);
    }

    public async List<Log> list_logs () {
        var logs = yield repository.get_logs ();
        return logs;
    }

    async void depopulate_trashs () {
        logs.remove_all ();

        var rlogs = yield repository.get_logs ();
        foreach (var l in rlogs) {
            repository.delete_log (l.id);
        }

        save_logs ();
    }

    void save_logs () {
        if (timeout_id != 0)
            Source.remove (timeout_id);

        timeout_id = Timeout.add (500, () => {
            timeout_id = 0;
            repository.save.begin ();
            return Source.REMOVE;
        });
    }
}
