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
        // Widgets
        [GtkChild]
        public Gtk.ListBox column;
        [GtkChild]
        public Gtk.Entry column_entry;
        [GtkChild]
        public Gtk.Label column_time_label;
        [GtkChild]
        public Gtk.Button column_button;
        [GtkChild]
        public Gtk.Button column_play_button;
        [GtkChild]
        public Gtk.MenuButton menu_button;
        [GtkChild]
        public Gtk.Button trash_button;
        [GtkChild]
        public Gtk.MenuButton menu_button2;
        [GtkChild]
        public Adw.ViewSwitcher win_switcher;
        [GtkChild]
        public Adw.ViewSwitcher win_switcher2;
        [GtkChild]
        public Gtk.Stack title_stack;
        [GtkChild]
        public Gtk.Stack win_stack;
        [GtkChild]
        public Gtk.Box placeholder;

        private GLib.ListStore liststore;

        public bool is_modified {get; set; default = false;}
        public bool start = false;
        private uint timer_id;
        private uint sec = 0;
        private uint min = 0;
        private uint hrs = 0;

        public TaskManager tm;
        public unowned Gtk.Application app { get; construct; }

        private uint id1 = 0; // 30min.
        private uint id2 = 0; // 1h.
        private uint id3 = 0; // 1h30min.
        private uint id4 = 0; // 2h
        private uint id5 = 0; // 2h30min.

        public SimpleActionGroup actions { get; set; }
        public const string ACTION_PREFIX = "win.";
        public const string ACTION_PREFS = "prefs";
        public const string ACTION_ABOUT = "about";
        public const string ACTION_EXPORT = "export";
        public const string ACTION_DELETE_ROW = "delete_row";
        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

        private const GLib.ActionEntry[] ACTION_ENTRIES = {
            { ACTION_PREFS, action_prefs },
            { ACTION_EXPORT, action_export },
            { ACTION_DELETE_ROW, action_delete_row },
            { ACTION_ABOUT, action_about }
        };

        public MainWindow (Gtk.Application application) {
            GLib.Object (
                application: application,
                app: application,
                icon_name: "io.github.lainsce.Khronos",
                title: "Khronos"
            );

            if (Khronos.Application.gsettings.get_boolean("dark-mode")) {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
            } else {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
            }

            actions = new SimpleActionGroup ();
            actions.add_action_entries (ACTION_ENTRIES, this);
            insert_action_group ("win", actions);

            foreach (var action in action_accelerators.get_keys ()) {
                var accels_array = action_accelerators[action].to_array ();
                accels_array += null;

                app.set_accels_for_action (ACTION_PREFIX + action, accels_array);
            }

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/io/github/lainsce/Khronos/stylesheet.css");
            Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (),
                                                      provider,
                                                      Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            var theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
            theme.add_resource_path ("/io/github/lainsce/Khronos/");

            Gtk.StyleContext style = get_style_context ();
            if (Config.PROFILE == "Devel") {
                style.add_class ("devel");
            }
        }

        construct {
            Adw.init ();
            tm = new TaskManager (this);

            Khronos.Application.gsettings.changed.connect (() => {
                if (Khronos.Application.gsettings.get_boolean("dark-mode")) {
                    Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
                } else {
                    Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
                }
            });

            liststore = new GLib.ListStore (typeof (Log));

            column_time_label.set_label ("<span font_features='tnum'>%02u∶%02u∶%02u</span>".printf(hrs, min, sec));

            column.row_activated.connect ((actrow) => {
                var row = ((LogRow)column.get_selected_row ());

                column_entry.set_text (row.log.name);
            });

            column_button.clicked.connect (() => {
                var log = new Log ();
                log.name = column_entry.text;

                var dt = new GLib.DateTime.now_local ();
                log.timedate = "%s\n%s - %s".printf(column_time_label.label,
                                                     ("<span font_features='tnum'>%s</span>").printf (dt.format ("%a, %d/%m %H∶%M∶%S")),
                                                     ("<span font_features='tnum'>%s</span>").printf (dt.add_full (0,0,0,(int)hrs,(int)min,(int)sec).format ("%H∶%M∶%S")));
                liststore.append (log);
                tm.save_to_file (liststore);
                reset_timer ();
                is_modified = true;
                column_entry.text = "";
                placeholder.visible = false;
            });

            column_play_button.clicked.connect (() => {
                if (start != true) {
                    start = true;
                    // For some reason, add() is closer to real time than add_seconds()
                    timer_id = GLib.Timeout.add (1000, () => {
                        timer ();
                        return true;
                    });;
                    column_play_button.label = _("Stop Timer");
                    column_play_button.get_style_context ().add_class ("destructive-action");
                    column_button.sensitive = false;
                } else {
                    start = false;
                    GLib.Source.remove(timer_id);
                    column_play_button.label = _("Start Timer");
                    column_play_button.get_style_context ().remove_class ("destructive-action");
                    column_play_button.get_style_context ().add_class ("suggested-action");
                    column_button.sensitive = true;
                }
            });

            column_entry.changed.connect (() => {
                if (column_entry.text_length != 0) {
                    column_play_button.sensitive = true;
                } else {
                    column_play_button.sensitive = false;
                }
                column.unselect_all ();
            });

            win_stack.notify["visible-child-name"].connect (() => {
                if (win_stack.get_visible_child_name () == "main") {
                    title_stack.set_visible_child_name ("main_title");
                } else {
                    title_stack.set_visible_child_name ("logs_title");
                }
            });

            var builder = new Gtk.Builder.from_resource ("/io/github/lainsce/Khronos/mainmenu.ui");
            menu_button.menu_model = (MenuModel)builder.get_object ("menu");
            menu_button2.menu_model = (MenuModel)builder.get_object ("menu");

            trash_button.clicked.connect (() => {
                liststore.remove_all ();
                placeholder.visible = true;
            });

            tm.load_from_file ();

            this.set_size_request (360, 360);
            this.show ();
            this.present ();

            set_timeouts ();
            listen_to_changes ();
            liststore.items_changed.connect (() => {
                tm.save_to_file (liststore);

                if (liststore.get_n_items () == 0) {
                    placeholder.visible = true;
                }
            });
        }

        protected override bool close_request () {
            debug ("Exiting window... Disposing of stuff...");
            column.bind_model (null, null);
            this.dispose ();
            return true;
        }

        public void listen_to_changes () {
            column.bind_model (liststore, item => make_widgets (item));
            Khronos.Application.gsettings.bind ("window-width", this, "default-width", GLib.SettingsBindFlags.DEFAULT);
            Khronos.Application.gsettings.bind ("window-height", this, "default-height", GLib.SettingsBindFlags.DEFAULT);
        }

        public LogRow make_widgets (GLib.Object item) {
            return new LogRow ((Log) item);
        }

        public void reset_timer () {
            sec = 0;
            min = 0;
            hrs = 0;
            column_time_label.label = "<span font_features='tnum'>%02u∶%02u∶%02u</span>".printf(hrs, min, sec);
            column_button.sensitive = false;
            column_entry.text = "";
        }

        public void add_task (string name, string timedate) {
            var log = new Log ();
            log.name = name;
            log.timedate = timedate;

            liststore.append(log);
        }

        public void timer () {
            if (start) {
                sec += 1;
                column_time_label.label = "<span font_features='tnum'>%02u∶%02u∶%02u</span>".printf(hrs, min, sec);
                if (sec >= 60) {
                    sec = 0;
                    min += 1;
                    column_time_label.label = "<span font_features='tnum'>%02u∶%02u∶%02u</span>".printf(hrs, min, sec);
                    if (min >= 60) {
                        min = 0;
                        hrs += 1;
                        column_time_label.label = "<span font_features='tnum'>%02u∶%02u∶%02u</span>".printf(hrs, min, sec);
                    }
                }
            }
        }

        public void set_timeouts () {
            if (start) {
                id1 = Timeout.add_seconds (Khronos.Application.gsettings.get_int("notification-delay"), () => {
                    notification1 ();
                    GLib.Source.remove (this.id2);
                    GLib.Source.remove (this.id3);
                    GLib.Source.remove (this.id4);
                    GLib.Source.remove (this.id5);
                    return true;
                });
                id2 = Timeout.add_seconds ((int) GLib.Math.floor (Khronos.Application.gsettings.get_int("notification-delay")*1.5), () => {
                    notification2 ();
                    GLib.Source.remove (this.id1);
                    GLib.Source.remove (this.id3);
                    GLib.Source.remove (this.id4);
                    GLib.Source.remove (this.id5);
                    return true;
                });
                id3 = Timeout.add_seconds (Khronos.Application.gsettings.get_int("notification-delay")*2, () => {
                    notification3 ();
                    GLib.Source.remove (this.id2);
                    GLib.Source.remove (this.id1);
                    GLib.Source.remove (this.id4);
                    GLib.Source.remove (this.id5);
                    return true;
                });
                id4 = Timeout.add_seconds ((int) GLib.Math.floor (Khronos.Application.gsettings.get_int("notification-delay")*2.5), () => {
                    notification4 ();
                    GLib.Source.remove (this.id2);
                    GLib.Source.remove (this.id1);
                    GLib.Source.remove (this.id3);
                    GLib.Source.remove (this.id5);
                    return true;
                });
                id5 = Timeout.add_seconds (Khronos.Application.gsettings.get_int("notification-delay")*3, () => {
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
            var notification1 = new GLib.Notification ("%i minutes have passed".printf(Khronos.Application.gsettings.get_int("notification-delay")));
            notification1.set_body (_("Go rest for a while before continuing."));
            var icon = new GLib.ThemedIcon ("appointment-symbolic");
            notification1.set_icon (icon);

            application.send_notification ("io.github.lainsce.Khronos", notification1);
        }

        public void notification2 () {
            var notification2 = new GLib.Notification ("%i minutes have passed".printf((int) GLib.Math.floor (Khronos.Application.gsettings.get_int("notification-delay")*1.5)));
            notification2.set_body (_("Go rest for a while before continuing."));
            var icon = new GLib.ThemedIcon ("appointment-symbolic");
            notification2.set_icon (icon);

            application.send_notification ("io.github.lainsce.Khronos", notification2);
        }

        public void notification3 () {
            var notification3 = new GLib.Notification ("%i minutes have passed".printf(Khronos.Application.gsettings.get_int("notification-delay")*2));
            notification3.set_body (_("Go rest for a while before continuing."));
            var icon = new GLib.ThemedIcon ("appointment-symbolic");
            notification3.set_icon (icon);

            application.send_notification ("io.github.lainsce.Khronos", notification3);
        }

        public void notification4 () {
            var notification4 = new GLib.Notification ("%i minutes have passed".printf((int) GLib.Math.floor (Khronos.Application.gsettings.get_int("notification-delay")*2.5)));
            notification4.set_body (_("Go rest for a while before continuing."));
            var icon = new GLib.ThemedIcon ("appointment-symbolic");
            notification4.set_icon (icon);

            application.send_notification ("io.github.lainsce.Khronos", notification4);
        }

        public void notification5 () {
            var notification5 = new GLib.Notification ("%i minutes have passed".printf(Khronos.Application.gsettings.get_int("notification-delay")*3));
            notification5.set_body (_("Go rest for a while before continuing."));
            var icon = new GLib.ThemedIcon ("appointment-symbolic");
            notification5.set_icon (icon);

            application.send_notification ("io.github.lainsce.Khronos", notification5);
        }

        public void action_delete_row () {
            uint i, n = liststore.get_n_items ();
            for (i = 0; i < n; i++) {
                liststore.remove (i);
            }
        }

        public void action_export () {
            FileManager.save_as.begin (liststore);
        }

        public void action_prefs () {
            var prefs = new Prefs ();
            prefs.show ();
            prefs.set_transient_for (this);
            prefs.delay = Khronos.Application.gsettings.get_int("notification-delay") / 60;

            Khronos.Application.gsettings.bind ("dark-mode", prefs.darkmode, "active", GLib.SettingsBindFlags.DEFAULT);
        }

        public void action_about () {
            const string COPYRIGHT = "Copyright \xc2\xa9 2019-2021 Paulo \"Lains\" Galardi\n";

            const string? AUTHORS[] = {
                "Paulo \"Lains\" Galardi",
                null
            };

            var program_name = Config.NAME_PREFIX + _("Khronos");
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
    }
}
