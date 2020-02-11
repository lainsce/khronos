/*
* Copyright (c) 2018 Lains
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

            tm.load_from_file ();

            grid = new Gtk.Grid ();
            grid.column_spacing = 12;
            grid.margin = 12;
            grid.set_column_homogeneous (true);
            grid.hexpand = true;
            grid.attach (column, 0, 0, 1, 2);
            grid.show_all ();

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            box.hexpand = true;
            box.pack_start (grid, false, true, 0);

            var scrwindow = new Gtk.ScrolledWindow (null, null);
            scrwindow.add (box);

            this.add (scrwindow);
            this.set_size_request (600, 600);
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
    }
}
