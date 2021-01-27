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
    public class MainWindow : Adw.ApplicationWindow {
        delegate void HookFunc ();
        // Widgets
        public Gtk.ListBox column;
        public Gtk.Entry column_entry;
        public Gtk.Label column_time_label;
        public Gtk.Button column_button;
        public Gtk.Button column_play_button;
        private GLib.ListStore ls;

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
                title: (_("Khronos"))
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

            var titlebar = new Adw.HeaderBar ();
            titlebar.get_style_context ().add_class ("flat-titlebar");
            titlebar.set_hexpand (true);

            ls = new GLib.ListStore (typeof (Log));
            ls.items_changed.connect (() => {
                tm.save_to_file (ls);
            });

            column = new Gtk.ListBox ();
            column.set_margin_top (18);
            column.set_margin_bottom (18);
            column.get_style_context ().add_class ("content");
            column.bind_model (ls, item => new LogRow ((Log) item));
            column.set_selection_mode (Gtk.SelectionMode.SINGLE);

            column.row_activated.connect ((actrow) => {
                var row = ((LogRow)column.get_selected_row ());

                column_entry.set_text (row.log.name);
            });

            column_time_label = new Gtk.Label("");
            column_time_label.set_use_markup (true);
            column_time_label.set_label ("<span font_features='tnum'>%02u∶%02u∶%02u</span>".printf(hrs, min, sec));
            column_time_label.get_style_context ().add_class ("kh-title");

            column_play_button = new Gtk.Button ();
            column_play_button.set_label (_("Start Timer"));
            column_play_button.set_can_focus (false);
            column_play_button.set_sensitive (false);
            column_play_button.halign = Gtk.Align.CENTER;
            column_play_button.get_style_context ().add_class ("suggested-action");
            column_play_button.get_style_context ().add_class ("circular");

            column_button = new Gtk.Button ();
            column_button.label = _("Add Log");
            column_button.can_focus = false;
            column_button.sensitive = false;
            column_button.halign = Gtk.Align.CENTER;
            column_button.get_style_context ().add_class ("circular");

            column_button.clicked.connect (() => {
                var log = new Log ();
                log.name = column_entry.text;

                var dt = new GLib.DateTime.now_local ();
                log.timedate = "%s\n%s - %s".printf(column_time_label.label,
                                                     ("<span font_features='tnum'>%s</span>").printf (dt.format ("%a, %d/%m %H∶%M∶%S")),
                                                     ("<span font_features='tnum'>%s</span>").printf (dt.add_full (0,0,0,(int)hrs,(int)min,(int)sec).format ("%H∶%M∶%S")));
                ls.append (log);
                tm.save_to_file (ls);
                reset_timer ();
                is_modified = true;
                column_entry.text = "";
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

            column_entry = new Gtk.Entry ();
            column_entry.margin_bottom = column_entry.margin_top = 24;
            column_entry.placeholder_text = _("New log name…");

            column_entry.changed.connect (() => {
                if (column_entry.text_length != 0) {
                    column_play_button.sensitive = true;
                } else {
                    column_play_button.sensitive = false;
                }
                column.unselect_all ();
            });

            var column_buttons_grid = new Gtk.Grid ();
            column_buttons_grid.column_spacing = 12;
            column_buttons_grid.attach (column_play_button, 0, 0);
            column_buttons_grid.attach (column_button, 1, 0);

            var size_group = new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL);
            size_group.add_widget (column_play_button);
            size_group.add_widget (column_button);

            var main_frame = new Gtk.Grid ();
            main_frame.orientation = Gtk.Orientation.VERTICAL;
            main_frame.valign = Gtk.Align.CENTER;
            main_frame.halign = Gtk.Align.CENTER;
            main_frame.hexpand = true;
            main_frame.attach (column_time_label, 0, 0);
            main_frame.attach (column_entry, 0, 1);
            main_frame.attach (column_buttons_grid, 0, 2);

            var builder = new Gtk.Builder.from_resource ("/io/github/lainsce/Khronos/mainmenu.ui");

            var menu_button = new Gtk.MenuButton ();
            menu_button.set_icon_name ("open-menu-symbolic");
            menu_button.has_tooltip = true;
            menu_button.tooltip_text = (_("Settings"));
            menu_button.menu_model = (MenuModel)builder.get_object ("menu");

            titlebar.pack_end (menu_button);

            tm.load_from_file ();

            var tgrid = new Gtk.Grid ();
            tgrid.attach (titlebar, 0, 0, 2, 1);

            var column_label = new Gtk.Label (_("Logs"));
            column_label.set_halign (Gtk.Align.START);
            column_label.set_hexpand (true);
            column_label.set_margin_top (18);
            column_label.get_style_context ().add_class ("heading");

            var cgrid = new Gtk.Grid ();
            cgrid.attach (column_label, 0, 0, 1, 1);
            cgrid.attach (column, 0, 2, 1, 1);

            var clamp = new Adw.Clamp ();
            clamp.set_child (cgrid);

            var mgrid = new Gtk.Grid ();
            mgrid.vexpand = true;
            mgrid.attach (main_frame, 0, 1, 1, 1);
            mgrid.attach (clamp, 0, 2, 1, 1);

            var scroller = new Gtk.ScrolledWindow ();
            scroller.hscrollbar_policy = Gtk.PolicyType.NEVER;
            scroller.set_child (mgrid);

            var grid = new Gtk.Grid ();
            grid.set_hexpand (true);
            grid.set_vexpand (true);
            grid.attach (tgrid, 0, 1, 1, 1);
            grid.attach (scroller, 0, 2, 1, 1);

            this.set_child (grid);
            this.set_size_request (360, 360);
            this.show ();

            set_timeouts ();
            listen_to_resize ();
        }

        protected override void dispose () {
            column.bind_model (null, null);
            base.dispose ();
        }

        public void listen_to_resize () {
            Khronos.Application.gsettings.bind ("window-width", this, "default-width", GLib.SettingsBindFlags.DEFAULT);
            Khronos.Application.gsettings.bind ("window-height", this, "default-height", GLib.SettingsBindFlags.DEFAULT);
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

            ls.append(log);
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
            uint i, n = ls.get_n_items ();
            for (i = 0; i < n; i++) {
                ls.remove (i);
            }
        }

        public void action_export () {
            FileManager.save_as.begin (ls);
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
                "Paulo \"Lains\" Galardi"
            };

            var program_name = Config.NAME_PREFIX + _("Khronos");
            Gtk.show_about_dialog (this,
                                   "program-name", program_name,
                                   "logo-icon-name", Config.APP_ID,
                                   "version", Config.VERSION,
                                   "comments", _("Track each task\'s time in a simple inobtrusive way."),
                                   "copyright", COPYRIGHT,
                                   "authors", AUTHORS,
                                   "license-type", Gtk.License.GPL_3_0,
                                   "wrap-license", false,
                                   "translator-credits", _("translator-credits"),
                                   null);
        }
    }
}
