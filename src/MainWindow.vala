/*
* Copyright (c) 2020-2021 Lains
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
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
namespace Khronos {
    [GtkTemplate (ui = "/io/github/lainsce/Khronos/main_window.ui")]
    public class MainWindow : Adw.ApplicationWindow {
        delegate void HookFunc ();
        public signal void clicked ();

        // Widgets
        [GtkChild]
        public unowned Gtk.Entry column_entry;
        [GtkChild]
        public unowned Gtk.Label column_time_label;
        [GtkChild]
        public unowned Gtk.Button add_log_button;
        [GtkChild]
        public unowned Gtk.Button timer_button;
        [GtkChild]
        public unowned Gtk.MenuButton menu_button;
        [GtkChild]
        public unowned Gtk.Button trash_button;
        [GtkChild]
        public unowned LogListView listview;

        public bool is_modified {get; set; default = false;}
        public bool start = false;
        private uint timer_id;
        private uint sec = 0;
        private uint min = 0;
        private uint hrs = 0;

        public GLib.DateTime dt;
        public unowned Gtk.Application app { get; construct; }
        public LogViewModel view_model { get; construct; }

        private uint id1 = 0; // 30min.
        private uint id2 = 0; // 1h.
        private uint id3 = 0; // 1h30min.
        private uint id4 = 0; // 2h
        private uint id5 = 0; // 2h30min.

        private const int NOTIF_DELAY = 1800;

        public SimpleActionGroup actions { get; set; }
        public const string ACTION_PREFIX = "win.";
        public const string ACTION_ABOUT = "about";
        public const string ACTION_EXPORT = "export";
        public const string ACTION_IMPORT = "import";
        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

        private const GLib.ActionEntry[] ACTION_ENTRIES = {
            { ACTION_EXPORT, action_export },
            { ACTION_IMPORT, action_import },
            { ACTION_ABOUT, action_about }
        };

        public MainWindow (Adw.Application application, LogViewModel view_model) {
            GLib.Object (
                application: application,
                app: application,
                view_model: view_model,
                icon_name: "io.github.lainsce.Khronos",
                title: "Khronos"
            );

            actions = new SimpleActionGroup ();
            actions.add_action_entries (ACTION_ENTRIES, this);
            insert_action_group ("win", actions);

            foreach (var action in action_accelerators.get_keys ()) {
                var accels_array = action_accelerators[action].to_array ();
                accels_array += null;

                app.set_accels_for_action (ACTION_PREFIX + action, accels_array);
            }

            var theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
            theme.add_resource_path ("/io/github/lainsce/Khronos/");
        }

        construct {
            // Migrate things from old version
            var settings = new Settings ();
            if (settings.schema_version == 0) {
                var mm = new MigrationManager (this);
                mm.load_from_file ();
                settings.schema_version = 1;
            }
            set_timeouts ();

            timer_button.clicked.connect (() => {
                if (start != true) {
                    start = true;
                    dt = new GLib.DateTime.now_local ();
                    // For some reason, add() is closer to real time than add_seconds()
                    timer_id = GLib.Timeout.add (998, () => {
                        timer ();
                        return true;
                    });;
                    timer_button.icon_name = "media-playback-stop-symbolic";
                    timer_button.tooltip_text = _("Stops the timer for a log");
                    timer_button.get_style_context ().remove_class ("accent-button");
                    timer_button.get_style_context ().add_class ("destructive-action");
                    add_log_button.sensitive = false;
                } else {
                    start = false;
                    GLib.Source.remove(timer_id);
                    timer_button.icon_name = "media-playback-start-symbolic";
                    timer_button.tooltip_text = _("Starts the timer for a log");
                    timer_button.get_style_context ().remove_class ("destructive-action");
                    timer_button.get_style_context ().add_class ("accent-button");
                    add_log_button.sensitive = true;
                }
            });

            column_entry.changed.connect (() => {
                if (column_entry.text_length != 0) {
                    timer_button.sensitive = true;
                } else {
                    timer_button.sensitive = false;
                }
            });

            column_entry.activate.connect (() => {
                timer_button.activate ();
            });

            if (Config.PROFILE == "Devel")
                add_css_class ("devel");

            this.set_size_request (360, 360);
            this.show ();
        }

        [GtkCallback]
        void on_new_log_requested () {
            var log = new Log ();
            log.name = column_entry.text;
            log.timedate = "%s\n%s – %s".printf(column_time_label.label,
                                               ("%s").printf (dt.format ("%a, %d/%m %H∶%M∶%S")),
                                               ("%s").printf (dt.add_full (0,
                                                                           0,
                                                                           0,
                                                                           (int)hrs,
                                                                           (int)min,
                                                                           (int)sec).format ("%H∶%M∶%S")));
            reset_timer ();
            if (start != true) {
                dt = null;
            }
            is_modified = true;
            column_entry.text = "";
            view_model.create_new_log (log);
        }

        [GtkCallback]
        public void on_log_update_requested (Log log) {
            view_model.update_log (log);
        }

        [GtkCallback]
        public void on_log_removal_requested (Log log) {
            view_model.delete_log (log);
        }

        [GtkCallback]
        void on_clear_trash_requested () {
            view_model.delete_trash.begin (this);
        }

        public void action_export () {
            FileManager.save_logs.begin (view_model);
        }

        public void action_import () {
            load_logs.begin ();
        }

        public async void load_logs () throws Error {
            Gee.ArrayList<Log> logs = yield FileManager.load_as ();

            foreach (var log in logs) {
                view_model.create_new_log (log);
            }
        }

        public void action_about () {
            const string COPYRIGHT = "Copyright \xc2\xa9 2019-2021 Paulo \"Lains\" Galardi\n";

            const string? AUTHORS[] = {
                "Paulo \"Lains\" Galardi",
                null
            };

            var program_name = Config.NAME_PREFIX + ("Khronos");
            Gtk.show_about_dialog (this,
                                   "program-name", program_name,
                                   "logo-icon-name", Config.APP_ID,
                                   "version", Config.VERSION,
                                   "comments", _("Track each task\'s time in a simple inobtrusive way."),
                                   "copyright", COPYRIGHT,
                                   "authors", AUTHORS,
                                   "artists", null,
                                   "license-type", Gtk.License.GPL_3_0,
                                   "wrap-license", false,
                                   "translator-credits", _("translator-credits"),
                                   null);
        }

        public void reset_timer () {
            sec = 0;
            min = 0;
            hrs = 0;
            column_time_label.label = "%02u∶%02u∶%02u".printf(hrs, min, sec);
            add_log_button.sensitive = false;
            timer_button.sensitive = true;
            column_entry.text = "";
        }

        public void add_task (string id, string name, string timedate) {
            var log = new Log ();
            log.id = id;
            log.name = name;
            log.timedate = timedate;

            view_model.create_new_log (log);
        }

        public void timer () {
            if (start) {
                sec += 1;
                column_time_label.label = "%02u∶%02u∶%02u".printf(hrs, min, sec);
                if (sec >= 60) {
                    sec = 0;
                    min += 1;
                    column_time_label.label = "%02u∶%02u∶%02u".printf(hrs, min, sec);
                    if (min >= 60) {
                        min = 0;
                        hrs += 1;
                        column_time_label.label = "%02u∶%02u∶%02u".printf(hrs, min, sec);
                    }
                }
            }
        }

        public void set_timeouts () {
            if (start) {
                id1 = Timeout.add_seconds (NOTIF_DELAY, () => {
                    notification1 ();
                    GLib.Source.remove (this.id2);
                    GLib.Source.remove (this.id3);
                    GLib.Source.remove (this.id4);
                    GLib.Source.remove (this.id5);
                    return true;
                });
                id2 = Timeout.add_seconds ((int) GLib.Math.floor (NOTIF_DELAY*1.5), () => {
                    notification2 ();
                    GLib.Source.remove (this.id1);
                    GLib.Source.remove (this.id3);
                    GLib.Source.remove (this.id4);
                    GLib.Source.remove (this.id5);
                    return true;
                });
                id3 = Timeout.add_seconds (NOTIF_DELAY*2, () => {
                    notification3 ();
                    GLib.Source.remove (this.id1);
                    GLib.Source.remove (this.id2);
                    GLib.Source.remove (this.id4);
                    GLib.Source.remove (this.id5);
                    return true;
                });
                id4 = Timeout.add_seconds ((int) GLib.Math.floor (NOTIF_DELAY*2.5), () => {
                    notification4 ();
                    GLib.Source.remove (this.id1);
                    GLib.Source.remove (this.id2);
                    GLib.Source.remove (this.id3);
                    GLib.Source.remove (this.id5);
                    return true;
                });
                id5 = Timeout.add_seconds (NOTIF_DELAY*3, () => {
                    notification5 ();
                    GLib.Source.remove (this.id1);
                    GLib.Source.remove (this.id2);
                    GLib.Source.remove (this.id3);
                    GLib.Source.remove (this.id4);
                    return true;
                });
            }
        }

        public void notification1 () {
            var notification1 = new GLib.Notification ("%i minutes have passed".printf(NOTIF_DELAY));
            notification1.set_body (_("Go rest for a while before continuing."));
            var icon = new GLib.ThemedIcon ("appointment-symbolic");
            notification1.set_icon (icon);

            application.send_notification ("io.github.lainsce.Khronos", notification1);
        }

        public void notification2 () {
            var notification2 = new GLib.Notification ("%i minutes have passed".printf((int) GLib.Math.floor (NOTIF_DELAY*1.5)));
            notification2.set_body (_("Maybe grab a snack before continuing."));
            var icon = new GLib.ThemedIcon ("appointment-symbolic");
            notification2.set_icon (icon);

            application.send_notification ("io.github.lainsce.Khronos", notification2);
        }

        public void notification3 () {
            var notification3 = new GLib.Notification ("%i minutes have passed".printf(NOTIF_DELAY*2));
            notification3.set_body (_("Perhaps go get some coffee or tea before continuing."));
            var icon = new GLib.ThemedIcon ("appointment-symbolic");
            notification3.set_icon (icon);

            application.send_notification ("io.github.lainsce.Khronos", notification3);
        }

        public void notification4 () {
            var notification4 = new GLib.Notification ("%i minutes have passed".printf((int) GLib.Math.floor (NOTIF_DELAY*2.5)));
            notification4.set_body (_("That's a big task. Let's rest a bit before continuing."));
            var icon = new GLib.ThemedIcon ("appointment-symbolic");
            notification4.set_icon (icon);

            application.send_notification ("io.github.lainsce.Khronos", notification4);
        }

        public void notification5 () {
            var notification5 = new GLib.Notification ("%i minutes have passed".printf(NOTIF_DELAY*3));
            notification5.set_body (_("Amazing work! But please rest a bit before continuing."));
            var icon = new GLib.ThemedIcon ("appointment-symbolic");
            notification5.set_icon (icon);

            application.send_notification ("io.github.lainsce.Khronos", notification5);
        }
    }
}
