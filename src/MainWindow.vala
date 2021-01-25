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
    public class MainWindow : Hdy.ApplicationWindow {
        // Widgets
        public DayColumn column;
        public Gtk.Grid grid;
        public Gtk.Grid sgrid;
        public Gtk.Grid sort_type_grid;
        public Gtk.Box main_frame_grid;
        public Gtk.Entry column_entry;
        public Gtk.Label column_time_label;
        public Gtk.Button column_button;
        public Gtk.Button column_play_button;
        public Hdy.Leaflet leaflet;
        public Hdy.HeaderBar titlebar;
        public Hdy.HeaderBar fauxtitlebar;

        public bool is_modified {get; set; default = false;}
        public bool start = false;
        private uint timer_id;
        private uint sec = 0;
        private uint min = 0;
        private uint hrs = 0;
        private GLib.DateTime dt;

        public TaskManager tm;
        public Gtk.Application app { get; construct; }

        private uint id1 = 0; // 30min.
        private uint id2 = 0; // 1h.
        private uint id3 = 0; // 1h30min.
        private uint id4 = 0; // 2h
        private uint id5 = 0; // 2h40min.

        public MainWindow (Gtk.Application application) {
            GLib.Object (
                application: application,
                app: application,
                icon_name: "io.github.lainsce.Khronos",
                title: (_("Khronos"))
            );

            key_press_event.connect ((e) => {
                uint keycode = e.hardware_keycode;

                if ((e.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
                    if (match_keycode (Gdk.Key.q, keycode)) {
                        this.destroy ();
                    }
                }
                return false;
            });

            if (Khronos.Application.gsettings.get_boolean("dark-mode")) {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
            } else {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
            }
        }

        construct {
            Hdy.init ();
            tm = new TaskManager (this);
            dt = new GLib.DateTime.now_local ();

            int x = Khronos.Application.gsettings.get_int("window-x");
            int y = Khronos.Application.gsettings.get_int("window-y");
            int h = Khronos.Application.gsettings.get_int("window-height");
            int w = Khronos.Application.gsettings.get_int("window-width");
            if (x != -1 && y != -1) {
                this.move (x, y);
            }
            if (w != 0 && h != 0) {
                this.resize (w, h);
            }

            Khronos.Application.gsettings.changed.connect (() => {
                if (Khronos.Application.gsettings.get_boolean("dark-mode")) {
                    Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
                } else {
                    Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
                }
            });

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/io/github/lainsce/Khronos/stylesheet.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                      provider,
                                                      Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            var theme = Gtk.IconTheme.get_default ();
            theme.add_resource_path ("/io/github/lainsce/Khronos/");


            titlebar = new Hdy.HeaderBar ();
            titlebar.show_close_button = true;
            titlebar.get_style_context ().add_class ("flat-titlebar");
            titlebar.has_subtitle = false;
            titlebar.title = "Khronos";
            titlebar.hexpand = true;
            titlebar.set_show_close_button (true);

            column = new DayColumn (this);

            column_time_label = new Gtk.Label("");
            column_time_label.use_markup = true;
            column_time_label.label = "<span font_features='tnum'>%02u∶%02u∶%02u</span>".printf(hrs, min, sec);
            column_time_label.get_style_context ().add_class ("kh-title");

            column_play_button = new Gtk.Button ();
            column_play_button.has_tooltip = true;
            column_play_button.label = _("Start Timer");
            column_play_button.can_focus = false;
            column_play_button.sensitive = false;
            column_play_button.halign = Gtk.Align.CENTER;
            column_play_button.get_style_context ().add_class ("suggested-action");
            column_play_button.get_style_context ().add_class ("circular-button");

            column_button = new Gtk.Button ();
            column_button.has_tooltip = true;
            column_button.label = _("Add Log");
            column_button.can_focus = false;
            column_button.sensitive = false;
            column_button.halign = Gtk.Align.CENTER;
            column_button.get_style_context ().add_class ("circular-button");

            column_button.clicked.connect (() => {
                add_task (column_entry.text, column_time_label.label, _("<span font_features='tnum'>%s</span>").printf (dt.format ("%a %d/%m %H∶%M")));
                column_entry.text = "";
            });

            column_play_button.clicked.connect (() => {
                if (start != true) {
                    start = true;
                    timer_id = GLib.Timeout.add_seconds (1, () => {
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
            });

            var column_buttons_grid = new Gtk.Grid ();
            column_buttons_grid.column_spacing = 12;
            column_buttons_grid.add (column_play_button);
            column_buttons_grid.add (column_button);

            var size_group = new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL);
            size_group.add_widget (column_play_button);
            size_group.add_widget (column_button);

            var main_frame = new Gtk.Grid ();
            main_frame.orientation = Gtk.Orientation.VERTICAL;
            main_frame.valign = Gtk.Align.CENTER;
            main_frame.halign = Gtk.Align.CENTER;
            main_frame.hexpand = true;
            main_frame.row_spacing = 6;
            main_frame.add (column_time_label);
            main_frame.add (column_entry);
            main_frame.add (column_buttons_grid);
            main_frame.show_all ();

            var sep = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

            var column_export_button = new Gtk.ModelButton ();
            column_export_button.text = _("Export Logs (CSV)…");

            column_export_button.clicked.connect (() => {
                try {
                    FileManager.save_as (this);
                } catch (Error e) {
                    warning ("Unexpected error during export: " + e.message);
                }
            });

            var prefs_button = new Gtk.ModelButton();
            prefs_button.text = _("Preferences");

            prefs_button.clicked.connect (() => {
               action_prefs ();
            });

            var about_button = new Gtk.ModelButton();
            about_button.text = _("About Khronos");

            about_button.clicked.connect (() => {
               action_about ();
            });

            var menu_grid = new Gtk.Grid ();
            menu_grid.margin = 10;
            menu_grid.row_spacing = 6;
            menu_grid.column_spacing = 6;
            menu_grid.orientation = Gtk.Orientation.VERTICAL;
            menu_grid.attach (column_export_button,0,0,2,1);
            menu_grid.attach (sep,0,1,2,1);
            menu_grid.attach (prefs_button,0,2,2,1);
            menu_grid.attach (about_button,0,3,2,1);
            menu_grid.show_all ();

            var menu = new Gtk.Popover (null);
            menu.add (menu_grid);

            var menu_button = new Gtk.MenuButton ();
            menu_button.set_image (new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
            menu_button.has_tooltip = true;
            menu_button.tooltip_text = (_("Settings"));
            menu_button.popover = menu;

            titlebar.pack_end (menu_button);

            tm.load_from_file ();

            var tgrid = new Gtk.Grid ();
            tgrid.attach (titlebar, 0, 0, 2, 1);
            tgrid.show_all ();

            var mgrid = new Gtk.Grid ();
            mgrid.vexpand = true;
            mgrid.attach (main_frame, 0, 1, 1, 1);
            mgrid.attach (column, 0, 2, 1, 1);
            mgrid.show_all ();

            var scroller = new Gtk.ScrolledWindow (null, null);
            scroller.hscrollbar_policy = Gtk.PolicyType.NEVER;
            scroller.add (mgrid);

            grid = new Gtk.Grid ();
            grid.expand = true;
            grid.attach (tgrid, 0, 1, 1, 1);
            grid.attach (scroller, 0, 2, 1, 1);
            grid.show_all ();

            this.add (grid);
            this.set_size_request (360, 360);
            this.show_all ();

            set_timeouts ();
        }

        #if VALA_0_42
        protected bool match_keycode (uint keyval, uint code) {
        #else
        protected bool match_keycode (int keyval, uint code) {
        #endif
            Gdk.KeymapKey [] keys;
            Gdk.Keymap keymap = Gdk.Keymap.get_for_display (Gdk.Display.get_default ());
            if (keymap.get_entries_for_keyval (keyval, out keys)) {
                foreach (var key in keys) {
                    if (code == key.keycode)
                        return true;
                    }
                }

            return false;
        }

        public override bool delete_event (Gdk.EventAny event) {
            int x, y, w, h;
            get_position (out x, out y);
            get_size (out w, out h);

            Khronos.Application.gsettings.set_int("window-x", x);
            Khronos.Application.gsettings.set_int("window-y", y);
            Khronos.Application.gsettings.set_int("window-width", w);
            Khronos.Application.gsettings.set_int("window-height", h);

            return false;
        }

        public void reset_timer () {
            sec = 0;
            min = 0;
            hrs = 0;
            column_time_label.label = "<span font_features='tnum'>%02u∶%02u∶%02u</span>".printf(hrs, min, sec);
            column_button.sensitive = false;
            column_entry.text = "";
        }

        public void add_task (string name, string time, string date) {
            var taskbox = new TaskBox (this, name, time, date);
            column.add (taskbox);
            tm.save_notes ();
            reset_timer ();
            is_modified = true;
        }

        public void clear_column () {
            foreach (Gtk.Widget item in column.get_children ()) {
                item.destroy ();
            }
            tm.save_notes ();
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
            var icon = new GLib.ThemedIcon ("appointment");
            notification1.set_icon (icon);

            application.send_notification ("io.github.lainsce.Khronos-symbolic", notification1);
        }

        public void notification2 () {
            var notification2 = new GLib.Notification ("%i minutes have passed".printf((int) GLib.Math.floor (Khronos.Application.gsettings.get_int("notification-delay")*1.5)));
            notification2.set_body (_("Go rest for a while before continuing."));
            var icon = new GLib.ThemedIcon ("appointment");
            notification2.set_icon (icon);

            application.send_notification ("io.github.lainsce.Khronos-symbolic", notification2);
        }

        public void notification3 () {
            var notification3 = new GLib.Notification ("%i minutes have passed".printf(Khronos.Application.gsettings.get_int("notification-delay")*2));
            notification3.set_body (_("Go rest for a while before continuing."));
            var icon = new GLib.ThemedIcon ("appointment");
            notification3.set_icon (icon);

            application.send_notification ("io.github.lainsce.Khronos-symbolic", notification3);
        }

        public void notification4 () {
            var notification4 = new GLib.Notification ("%i minutes have passed".printf((int) GLib.Math.floor (Khronos.Application.gsettings.get_int("notification-delay")*2.5)));
            notification4.set_body (_("Go rest for a while before continuing."));
            var icon = new GLib.ThemedIcon ("appointment");
            notification4.set_icon (icon);

            application.send_notification ("io.github.lainsce.Khronos-symbolic", notification4);
        }

        public void notification5 () {
            var notification5 = new GLib.Notification ("%i minutes have passed".printf(Khronos.Application.gsettings.get_int("notification-delay")*3));
            notification5.set_body (_("Go rest for a while before continuing."));
            var icon = new GLib.ThemedIcon ("appointment");
            notification5.set_icon (icon);

            application.send_notification ("io.github.lainsce.Khronos-symbolic", notification5);
        }

        public void action_prefs () {
            var prefs = new Prefs ();
            prefs.show_all ();
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
                                   "logo-icon-name", "io.github.lainsce.Khronos",
                                   "version", Config.VERSION,
                                   "comments", _("Track each task's time in a simple inobtrusive way."),
                                   "copyright", COPYRIGHT,
                                   "authors", AUTHORS,
                                   "license-type", Gtk.License.GPL_3_0,
                                   "wrap-license", false,
                                   "translator-credits", _("translator-credits"),
                                   null);
        }
    }
}
