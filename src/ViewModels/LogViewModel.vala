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
        var dialog = new Gtk.MessageDialog (win, 0, 0, 0, null);
        dialog.modal = true;

        dialog.set_title (_("Clear Logs?"));
        dialog.text = (_("Clearing means the logs here will be permanently lost with no recovery."));

        dialog.add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
        dialog.add_button (_("Clear"), Gtk.ResponseType.OK);

        dialog.response.connect ((response_id) => {
            switch (response_id) {
                case Gtk.ResponseType.OK:
                    depopulate_trashs.begin ();
                    win.logs_group.set_sensitive (false);
                    win.trash_button.set_sensitive (false);
                    dialog.close ();
                    break;
                case Gtk.ResponseType.NO:
                    dialog.close ();
                    break;
                case Gtk.ResponseType.CANCEL:
                case Gtk.ResponseType.CLOSE:
                case Gtk.ResponseType.DELETE_EVENT:
                default:
                    dialog.close ();
                    return;
            }
        });

        if (dialog != null) {
            dialog.present ();
            return;
        } else {
            dialog.show ();
        }
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
