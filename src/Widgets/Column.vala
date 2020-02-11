namespace Khronos {
    public class DayColumn : Gtk.Grid {
        private MainWindow win;
        private DayColumnListBox column;
        public Gtk.Label column_time_label;
        public bool is_modified {get; set; default = false;}
        private bool start = false;
        private uint timer_id;
        private uint sec = 0;
        private uint min = 0;

        public DayColumn (int day, MainWindow win) {
            this.win = win;
            this.set_size_request (180,-1);
            is_modified = false;
            column = new DayColumnListBox (day, win);

            var column_entry = new Gtk.Entry ();
            column_entry.placeholder_text = _("New task name…");
            column_entry.hexpand = true;
            column_entry.margin_top = 6;
            column_entry.margin_start = column_entry.margin_end = 12;
            column_entry.valign = Gtk.Align.START;

            column_time_label = new Gtk.Label("");
            column_time_label.set_markup (@"\n<span size=\"x-large\">0 mins, 0 secs</span>");
            column_time_label.margin_bottom = 6;
            column_time_label.valign = Gtk.Align.END;

            var column_play_button = new Gtk.Button ();
            column_play_button.can_focus = false;
            column_play_button.halign = Gtk.Align.START;
            column_play_button.valign = Gtk.Align.START;
            column_play_button.width_request = 42;
            column_play_button.height_request = 42;
            var column_play_button_style_context = column_play_button.get_style_context ();
            column_play_button_style_context.add_class ("tt-button");
            column_play_button_style_context.add_class ("image-button");
            column_play_button.set_image (new Gtk.Image.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.SMALL_TOOLBAR));

            var column_reset_button = new Gtk.Button ();
            column_reset_button.sensitive = false;
            column_reset_button.can_focus = false;
            column_reset_button.halign = Gtk.Align.START;
            column_reset_button.valign = Gtk.Align.END;
            column_reset_button.width_request = 42;
            column_reset_button.height_request = 42;
            var column_reset_button_style_context = column_reset_button.get_style_context ();
            column_reset_button_style_context.add_class ("tt-button");
            column_reset_button_style_context.add_class ("image-button");
            column_reset_button.set_image (new Gtk.Image.from_icon_name ("edit-clear-symbolic", Gtk.IconSize.SMALL_TOOLBAR));

            var column_button = new Gtk.Button ();
            column_button.can_focus = false;
            column_button.halign = Gtk.Align.END;
            column_button.valign = Gtk.Align.START;
            column_button.width_request = 42;
            column_button.height_request = 42;
            var column_button_style_context = column_button.get_style_context ();
            column_button_style_context.add_class ("tt-button");
            column_button_style_context.add_class ("image-button");
            column_button.set_image (new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR));

            column_button.clicked.connect (() => {
                add_task (column_entry.text, column_time_label.label);
                column_entry.text = "";
            });

            column_play_button.clicked.connect (() => {
                if (start != true) {
                    start = true;
                    timer_id = GLib.Timeout.add_seconds (1, () => {
                        timer ();
                        return true;
                    });;
                    column_play_button.set_image (new Gtk.Image.from_icon_name ("media-playback-stop-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
                    column_reset_button.sensitive = false;
                } else {
                    start = false;
                    GLib.Source.remove(timer_id);
                    column_play_button.set_image (new Gtk.Image.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
                    column_reset_button.sensitive = true;
                }
            });

            column_reset_button.clicked.connect (() => {
                column_time_label.set_markup (@"\n<span size=\"x-large\">0 mins, 0 secs</span>");
                sec = 0;
                min = 0;
            });

            this.row_spacing = 6;
            this.attach (column_play_button, 0, 0, 1, 1);
            this.attach (column_reset_button, 0, 1, 1, 1);
            this.attach (column_entry, 1, 0, 1, 1);
            this.attach (column_time_label, 1, 1, 1, 1);
            this.attach (column_button, 2, 0, 1, 2);
            this.attach (column, 0, 2, 3, 1);

            this.show_all ();
        }

        public void add_task (string name, string time) {
            var taskbox = new TaskBox (this.win, name, time);
            column.insert (taskbox, -1);
            win.tm.save_notes ();
            is_modified = true;
        }

        public void clear_column () {
            foreach (Gtk.Widget item in column.get_children ()) {
                item.destroy ();
            }
            win.tm.save_notes ();
        }

        // TODO: Think more about this
        public void timer () {
            if (start) {
                sec += 1;
                column_time_label.set_markup ("\n<span size=\"x-large\">"+"%u mins, %u secs".printf(min, sec)+"</span>");
                if (sec > 60) {
                    sec = 0;
                    min += 1;
                    column_time_label.set_markup ("\n<span size=\"x-large\">"+"%u mins, 0 secs".printf(min)+"</span>");
                }
            }
        }

        public Gee.ArrayList<TaskBox> get_tasks () {
            var tasks = new Gee.ArrayList<TaskBox> ();
            foreach (Gtk.Widget item in column.get_children ()) {
	            tasks.add ((TaskBox)item);
            }
            return tasks;
        }
    }
}
