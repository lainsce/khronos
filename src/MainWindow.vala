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
        public Gtk.Button column_export_button;
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

            if (Khronos.Application.gsettings.get_boolean("dark-mode")) {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
                titlebar.get_style_context ().add_class ("tt-toolbar-dark");
                main_frame_grid.get_style_context ().add_class ("tt-view-dark");
            } else {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
                titlebar.get_style_context ().remove_class ("tt-toolbar-dark");
                main_frame_grid.get_style_context ().remove_class ("tt-view-dark");
            }

            if (Khronos.Application.grsettings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK) {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
                titlebar.get_style_context ().add_class ("tt-toolbar-dark");
                main_frame_grid.get_style_context ().add_class ("tt-view-dark");
                Khronos.Application.gsettings.set_boolean("dark-mode", true);
            } else if (Khronos.Application.grsettings.prefers_color_scheme == Granite.Settings.ColorScheme.NO_PREFERENCE) {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
                titlebar.get_style_context ().remove_class ("tt-toolbar-dark");
                main_frame_grid.get_style_context ().remove_class ("tt-view-dark");
                Khronos.Application.gsettings.set_boolean("dark-mode", false);
            }

            Khronos.Application.grsettings.notify["prefers-color-scheme"].connect (() => {
                 if (Khronos.Application.grsettings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK) {
                     Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
                     titlebar.get_style_context ().add_class ("tt-toolbar-dark");
                     main_frame_grid.get_style_context ().add_class ("tt-view-dark");
                     Khronos.Application.gsettings.set_boolean("dark-mode", true);
                 } else if (Khronos.Application.grsettings.prefers_color_scheme == Granite.Settings.ColorScheme.NO_PREFERENCE) {
                     Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
                     titlebar.get_style_context ().remove_class ("tt-toolbar-dark");
                     main_frame_grid.get_style_context ().remove_class ("tt-view-dark");
                     Khronos.Application.gsettings.set_boolean("dark-mode", false);
                 }
            });
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
                if (Khronos.Application.gsettings.get_boolean("notification")) {
                    set_timeouts ();
                }
                if (Khronos.Application.gsettings.get_boolean("dark-mode")) {
                    Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
                    titlebar.get_style_context ().add_class ("tt-toolbar-dark");
                    main_frame_grid.get_style_context ().add_class ("tt-view-dark");
                } else {
                    Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
                    titlebar.get_style_context ().remove_class ("tt-toolbar-dark");
                    main_frame_grid.get_style_context ().remove_class ("tt-view-dark");
                }
            });

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/com/github/lainsce/khronos/stylesheet.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                      provider,
                                                      Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            titlebar = new Hdy.HeaderBar ();
            titlebar.show_close_button = true;
            var titlebar_style_context = titlebar.get_style_context ();
            titlebar_style_context.add_class (Gtk.STYLE_CLASS_FLAT);
            titlebar_style_context.add_class ("tt-toolbar");
            titlebar.has_subtitle = false;
            titlebar.title = " Khronos";
            titlebar.set_show_close_button (true);
            titlebar.hexpand = true;
            titlebar.decoration_layout = ":maximize";
            titlebar.set_size_request (-1,38);

            column = new DayColumn (1, this);
            column.column.hexpand = false;

            var sidebar_scroller = new Gtk.ScrolledWindow (null, null);
            sidebar_scroller.hscrollbar_policy = Gtk.PolicyType.NEVER;
            sidebar_scroller.add (column);

            column_time_label = new Gtk.Label("");
            column_time_label.use_markup = true;
            column_time_label.label = "%02u<span size=\"x-small\">H</span> %02u<span size=\"x-small\">M</span> %02u<span size=\"x-small\">S</span>".printf(hrs, min, sec);
            column_time_label.margin_top = 12;
            var column_time_label_style_context = column_time_label.get_style_context ();
            column_time_label_style_context.add_class ("tt-label");

            column_play_button = new Gtk.Button ();
            column_play_button.has_tooltip = true;
            column_play_button.tooltip_text = _("Start Timer…");
            column_play_button.can_focus = false;
            column_play_button.halign = Gtk.Align.CENTER;
            var column_play_button_style_context = column_play_button.get_style_context ();
            column_play_button_style_context.add_class ("tt-button");
            column_play_button_style_context.add_class ("image-button");
            column_play_button.set_image (new Gtk.Image.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.BUTTON));

            column_export_button = new Gtk.ModelButton ();
            var column_export_image = new Gtk.Image.from_icon_name ("x-office-spreadsheet-symbolic", Gtk.IconSize.BUTTON);
            column_export_button.get_child ().destroy ();
            var column_export_button_accellabel = new Granite.AccelLabel.from_action_name (
                _("Export Log as CSV File…"),
                ""
            );

            var column_export_button_box = new Gtk.Grid ();
            column_export_button_box.column_spacing = 6;
            column_export_button_box.add (column_export_image);
            column_export_button_box.add (column_export_button_accellabel);
            column_export_button.add (column_export_button_box);
            column_export_button.halign = Gtk.Align.START;
            column_export_button.can_focus = false;

            column_button = new Gtk.Button ();
            column_button.has_tooltip = true;
            column_button.tooltip_text = _("Add Log");
            column_button.can_focus = false;
            column_button.sensitive = false;
            column_button.halign = Gtk.Align.CENTER;
            var column_button_style_context = column_button.get_style_context ();
            column_button_style_context.add_class ("tt-button");
            column_button_style_context.add_class ("image-button");
            column_button.set_image (new Gtk.Image.from_icon_name ("appointment-new-symbolic", Gtk.IconSize.BUTTON));

            column_button.clicked.connect (() => {
                add_task (column_entry.text, column_time_label.label, _("%s").printf (dt.format ("%a %d/%m %H:%M")));
                column_entry.text = "";
            });

            column_play_button.clicked.connect (() => {
                if (start != true) {
                    start = true;
                    timer_id = GLib.Timeout.add_seconds (1, () => {
                        timer ();
                        return true;
                    });;
                    column_play_button.set_image (new Gtk.Image.from_icon_name ("media-playback-stop-symbolic", Gtk.IconSize.BUTTON));
                    column_play_button.tooltip_text = _("Stop Timer");
                    column_button.sensitive = false;
                } else {
                    start = false;
                    GLib.Source.remove(timer_id);
                    column_play_button.set_image (new Gtk.Image.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.BUTTON));
                    column_play_button.tooltip_text = _("Start Timer");
                    column_button.sensitive = true;
                }
            });

            column_export_button.clicked.connect (() => {
                try {
                    FileManager.save_as (this);
                } catch (Error e) {
                    warning ("Unexpected error during export: " + e.message);
                }
            });

            column_entry = new Gtk.Entry ();
            column_entry.placeholder_text = _("New log name…");
            column_entry.hexpand = true;
            column_entry.margin = 12;
            column_entry.valign = Gtk.Align.START;
            column_entry.get_style_context ().add_class ("tt-entry");

            column_entry.changed.connect (() => {
                if (column_entry.text_length != 0) {
                    column_play_button.sensitive = true;
                } else {
                    column_play_button.sensitive = false;
                }
            });

	        var custom_help = new Gtk.Image.from_icon_name ("dialog-information-symbolic", Gtk.IconSize.BUTTON);
            custom_help.halign = Gtk.Align.START;
	        custom_help.margin = 12;
            custom_help.tooltip_text = _("You can add a log by typing the log name and then starting the timer.");

            var column_buttons_grid = new Gtk.Grid ();
            column_buttons_grid.hexpand = true;
            column_buttons_grid.column_homogeneous = true;
            column_buttons_grid.margin = 6;
            column_buttons_grid.add (column_play_button);
            column_buttons_grid.add (column_button);

	        var column_entry_and_help_grid = new Gtk.Grid ();
	        column_entry_and_help_grid.add (column_entry);
            column_entry_and_help_grid.add (custom_help);
            column_entry_and_help_grid.attach (column_buttons_grid, 0, 1, 2, 1);

            var main_frame = new Gtk.Grid ();
            main_frame.orientation = Gtk.Orientation.VERTICAL;
            main_frame.valign = Gtk.Align.CENTER;
            main_frame.margin = 12;
            main_frame.add (column_time_label);
            main_frame.add (column_entry_and_help_grid);
            main_frame.show_all ();
            main_frame.get_style_context ().add_class ("card");
            main_frame.get_style_context ().add_class ("tt-card");

            var notification_header = new Granite.HeaderLabel (_("Notifications"));

            var notification_label = new Gtk.Label (_("Delay:"));
            notification_label.halign = Gtk.Align.END;

            var notification_sw = new Gtk.Switch ();
            notification_sw.valign = Gtk.Align.CENTER;
            notification_sw.halign = Gtk.Align.START;
            Khronos.Application.gsettings.bind ("notification", notification_sw, "active", GLib.SettingsBindFlags.DEFAULT);

            var notification_sb = new Gtk.SpinButton.with_range (30, 90, 1);
            notification_sb.set_text ("%i".printf((Khronos.Application.gsettings.get_int("notification-delay")/60)));
            Khronos.Application.gsettings.bind ("notification", notification_sb, "sensitive", GLib.SettingsBindFlags.DEFAULT);
            notification_sb.halign = Gtk.Align.START;

            notification_sb.value_changed.connect (() => {
                Khronos.Application.gsettings.set_int("notification-delay", ((int)notification_sb.value * 60));
            });

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

            var export_menu_grid = new Gtk.Grid ();
            export_menu_grid.margin = 12;
            export_menu_grid.row_spacing = 6;
            export_menu_grid.column_spacing = 12;
            export_menu_grid.orientation = Gtk.Orientation.VERTICAL;
            export_menu_grid.add (column_export_button);
            export_menu_grid.show_all ();

            var export_menu = new Gtk.Popover (null);
            export_menu.add (export_menu_grid);

            var export_menu_button = new Gtk.MenuButton ();
            export_menu_button.set_image (new Gtk.Image.from_icon_name ("document-properties-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
            export_menu_button.has_tooltip = true;
            export_menu_button.always_show_image = true;
            export_menu_button.label = (_("Export…"));
            export_menu_button.tooltip_text = (_("Export the Logs to a File"));
            export_menu_button.popover = export_menu;
            var export_menu_button_style_context = export_menu_button.get_style_context ();
            export_menu_button_style_context.add_class ("tt-sabutton");
            export_menu_button_style_context.add_class ("image-button");

            var sort_time = new Gtk.RadioButton.with_label_from_widget (null, _("Time"));
	        sort_time.toggled.connect (() => {
	            Khronos.Application.gsettings.set_string("sort-type", "time");
	            column.column.invalidate_sort ();
	        });

	        var sort_name = new Gtk.RadioButton.with_label_from_widget (sort_time, _("Name"));
	        sort_name.toggled.connect (() => {
	            Khronos.Application.gsettings.set_string("sort-type", "name");
	            column.column.invalidate_sort ();
	        });

	        if (Khronos.Application.gsettings.get_string("sort-type") == "name") {
	            sort_name.set_active (true);
	        } else {
	            sort_time.set_active (true);
	        }

	        var sort_header = new Granite.HeaderLabel (_("Tasks"));
	        var sort_label = new Gtk.Label (_("Sort By:"));
            sort_label.halign = Gtk.Align.END;

            var menu_grid = new Gtk.Grid ();
            menu_grid.margin = 12;
            menu_grid.row_spacing = 6;
            menu_grid.column_spacing = 12;
            menu_grid.orientation = Gtk.Orientation.VERTICAL;
            menu_grid.attach (sort_header,0,2,1,1);
            menu_grid.attach (sort_label,0,3,1,1);
            menu_grid.attach (sort_time,1,3,1,1);
            menu_grid.attach (sort_name,1,4,1,1);
            menu_grid.attach (notification_header,0,5,1,1);
            menu_grid.attach (notification_label,0,6,1,1);
            menu_grid.attach (notification_sw,1,6,1,1);
            menu_grid.attach (notification_sb,2,6,1,1);
            menu_grid.show_all ();

            var menu = new Gtk.Popover (null);
            menu.add (menu_grid);

            var menu_button = new Gtk.MenuButton ();
            menu_button.set_image (new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
            menu_button.has_tooltip = true;
            menu_button.tooltip_text = (_("Settings"));
            menu_button.popover = menu;
            var menu_button_style_context = menu_button.get_style_context ();
            menu_button_style_context.add_class ("tt-button");
            menu_button_style_context.add_class ("image-button");

            var sidebar_actionbar = new Gtk.ActionBar ();
            sidebar_actionbar.get_style_context ().add_class ("tt-sabar");
            sidebar_actionbar.add (export_menu_button);
            sidebar_actionbar.pack_end (menu_button);

            tm.load_from_file ();

            fauxtitlebar = new Hdy.HeaderBar ();
            fauxtitlebar.set_size_request (200,38);
            fauxtitlebar.decoration_layout = "close:";
            fauxtitlebar.show_close_button = true;
            fauxtitlebar.has_subtitle = false;
            fauxtitlebar.get_style_context ().add_class ("tt-column");
            fauxtitlebar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            sgrid = new Gtk.Grid ();
            sgrid.attach (fauxtitlebar, 0, 0, 1, 1);
            sgrid.attach (sidebar_scroller, 0, 1, 1, 1);
            sgrid.attach (sidebar_actionbar, 0, 2, 1, 1);
            sgrid.show_all ();

            main_frame_grid = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            main_frame_grid.expand = true;
            main_frame_grid.get_style_context ().add_class ("tt-view");
            main_frame_grid.add (main_frame);

            grid = new Gtk.Grid ();
            grid.attach (titlebar, 1, 0, 1, 1);
            grid.attach (main_frame_grid, 1, 1, 1, 1);
            grid.show_all ();

            update ();

            leaflet = new Hdy.Leaflet ();
            leaflet.add (sgrid);
            leaflet.add (grid);
            leaflet.transition_type = Hdy.LeafletTransitionType.UNDER;
            leaflet.show_all ();
            leaflet.can_swipe_back = true;
            leaflet.set_visible_child (grid);

            leaflet.notify["folded"].connect (() => {
                update ();
            });

            this.add (leaflet);
            this.set_size_request (360, 435);
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

        private void update () {
            if (leaflet != null && leaflet.get_folded ()) {
                // On Mobile size, so.... have to have no buttons anywhere.
                fauxtitlebar.set_decoration_layout (":");
                titlebar.set_decoration_layout (":");
            } else {
                // Else you're on Desktop size, so business as usual.
                fauxtitlebar.set_decoration_layout ("close:");
                titlebar.set_decoration_layout (":maximize");
            }
        }

        public void reset_timer () {
            sec = 0;
            min = 0;
            hrs = 0;
            column_time_label.label = "%02u<span size=\"x-small\">H</span> %02u<span size=\"x-small\">M</span> %02u<span size=\"x-small\">S</span>".printf(hrs, min, sec);
            column_button.sensitive = false;
            column_entry.text = "";
        }

        public void add_task (string name, string time, string date) {
            var taskbox = new TaskBox (this, name, time, date);
            column.column.insert (taskbox, -1);
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
                column_time_label.label = "%02u<span size=\"x-small\">H</span> %02u<span size=\"x-small\">M</span> %02u<span size=\"x-small\">S</span>".printf(hrs, min, sec);
                if (sec >= 60) {
                    sec = 0;
                    min += 1;
                    column_time_label.label = "%02u<span size=\"x-small\">H</span> %02u<span size=\"x-small\">M</span> %02u<span size=\"x-small\">S</span>".printf(hrs, min, sec);
                    if (min >= 60) {
                        min = 0;
                        hrs += 1;
                        column_time_label.label = "%02u<span size=\"x-small\">H</span> %02u<span size=\"x-small\">M</span> %02u<span size=\"x-small\">S</span>".printf(hrs, min, sec);
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

            application.send_notification ("com.github.lainsce.khronos", notification1);
        }

        public void notification2 () {
            var notification2 = new GLib.Notification ("%i minutes have passed".printf((int) GLib.Math.floor (Khronos.Application.gsettings.get_int("notification-delay")*1.5)));
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
            var notification4 = new GLib.Notification ("%i minutes have passed".printf((int) GLib.Math.floor (Khronos.Application.gsettings.get_int("notification-delay")*2.5)));
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
