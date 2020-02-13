/*
* Copyright (c) 2020 Lains
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
    public class MainWindow : Gtk.ApplicationWindow {
        // Widgets
        public DayColumn column;
        public Gtk.Grid grid;

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
                icon_name: "com.github.lainsce.khronos",
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
        }

        construct {
            tm = new TaskManager (this);

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
                if (Khronos.Application.gsettings.get_boolean("notification")) {
                    set_timeouts ();
                }
            });

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/com/github/lainsce/khronos/stylesheet.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                      provider,
                                                      Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            this.get_style_context ().add_class ("rounded");

            var titlebar = new Gtk.HeaderBar ();
            titlebar.show_close_button = true;
            var titlebar_style_context = titlebar.get_style_context ();
            titlebar_style_context.add_class ("tt-toolbar");
            titlebar_style_context.add_class (Gtk.STYLE_CLASS_FLAT);
            titlebar.has_subtitle = false;
            titlebar.set_show_close_button (true);
            titlebar.decoration_layout = "close:";
            this.set_titlebar (titlebar);

            column = new DayColumn (1, this);

            var actionbar = new Gtk.ActionBar();
            var actionbar_style_context = actionbar.get_style_context ();
            actionbar_style_context.add_class (Gtk.STYLE_CLASS_FLAT);

            var notification_label = new Gtk.Label (_("Notification Delay:"));

            var notification_sw = new Gtk.Switch ();
            notification_sw.valign = Gtk.Align.CENTER;
            Khronos.Application.gsettings.bind ("notification", notification_sw, "active", GLib.SettingsBindFlags.DEFAULT);

            var notification_sb = new Gtk.SpinButton.with_range (30, 90, 1);
            notification_sb.set_text ("%i".printf((Khronos.Application.gsettings.get_int("notification-delay")/60)));

            notification_sb.sensitive = notification_sw.get_active ();

            notification_sb.value_changed.connect (() => {
                Khronos.Application.gsettings.set_int("notification-delay", ((int)notification_sb.value * 60));
            });

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

            var notification_box = new Gtk.Grid ();
            notification_box.column_spacing = 6;
            notification_box.add (notification_label);
            notification_box.add (notification_sw);
            notification_box.add (notification_sb);
            notification_box.show_all ();

            var menu_grid = new Gtk.Grid ();
            menu_grid.margin = 6;
            menu_grid.row_spacing = 6;
            menu_grid.column_spacing = 12;
            menu_grid.orientation = Gtk.Orientation.VERTICAL;
            menu_grid.add (notification_box);
            menu_grid.show_all ();

            var menu = new Gtk.Popover (null);
            menu.add (menu_grid);

            var menu_button = new Gtk.MenuButton ();
            menu_button.set_image (new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
            menu_button.has_tooltip = true;
            menu_button.tooltip_text = (_("Settings"));
            menu_button.popover = menu;

            actionbar.pack_end (menu_button);

            tm.load_from_file ();

            grid = new Gtk.Grid ();
            grid.column_spacing = 12;
            grid.margin = 12;
            grid.set_column_homogeneous (true);
            grid.hexpand = true;
            grid.attach (column, 0, 0, 1, 1);
            grid.attach (actionbar, 0, 1, 1, 1);
            grid.show_all ();

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            box.hexpand = true;
            box.pack_start (grid, false, true, 0);

            var scrwindow = new Gtk.ScrolledWindow (null, null);
            scrwindow.add (box);

            this.add (scrwindow);
            this.set_size_request (600, 900);
            this.show_all ();
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

        public void set_timeouts () {
            if (column.start) {
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

            application.send_notification ("com.github.lainsce.khronos", notification1);
        }

        public void notification2 () {
            var notification2 = new GLib.Notification ("%i minutes have passed".printf((uint) GLib.Math.floor (Khronos.Application.gsettings.get_int("notification-delay")*1.5)));
            notification2.set_body (_("Go rest for a while before continuing."));
            var icon = new GLib.ThemedIcon ("appointment");
            notification2.set_icon (icon);

            application.send_notification ("com.github.lainsce.khronos", notification2);
        }

        public void notification3 () {
            var notification3 = new GLib.Notification ("%i minutes have passed".printf(Khronos.Application.gsettings.get_int("notification-delay")*2));
            notification3.set_body (_("Go rest for a while before continuing."));
            var icon = new GLib.ThemedIcon ("appointment");
            notification3.set_icon (icon);

            application.send_notification ("com.github.lainsce.khronos", notification3);
        }

        public void notification4 () {
            var notification4 = new GLib.Notification ("%i minutes have passed".printf((uint) GLib.Math.floor (Khronos.Application.gsettings.get_int("notification-delay")*2.5)));
            notification4.set_body (_("Go rest for a while before continuing."));
            var icon = new GLib.ThemedIcon ("appointment");
            notification4.set_icon (icon);

            application.send_notification ("com.github.lainsce.khronos", notification4);
        }

        public void notification5 () {
            var notification5 = new GLib.Notification ("%i minutes have passed".printf(Khronos.Application.gsettings.get_int("notification-delay")*3));
            notification5.set_body (_("Go rest for a while before continuing."));
            var icon = new GLib.ThemedIcon ("appointment");
            notification5.set_icon (icon);

            application.send_notification ("com.github.lainsce.khronos", notification5);
        }
    }
}
