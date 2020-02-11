namespace Khronos {
    public class DayColumn : Gtk.Grid {
        private MainWindow win;
        private DayColumnListBox column;
        public bool is_modified {get; set; default = false;}

        public DayColumn (int day, MainWindow win) {
            this.win = win;
            this.set_size_request (180,-1);
            is_modified = false;
            column = new DayColumnListBox (day, win);

            var column_entry = new Gtk.Entry ();
            column_entry.placeholder_text = _("New task name");
            column_entry.hexpand = true;
            column_entry.margin = 12;

            var column_time_label = new Gtk.Label("00:00:00");
            column_time_label.set_markup (@"\n<span size=\"x-large\">"+timer ()+"</span>");

            var column_play_button = new Gtk.Button ();
            column_play_button.can_focus = false;
            column_play_button.halign = Gtk.Align.START;
            column_play_button.valign = Gtk.Align.CENTER;
            column_play_button.width_request = 42;
            column_play_button.height_request = 42;
            var column_play_button_style_context = column_play_button.get_style_context ();
            column_play_button_style_context.add_class ("tt-button");
            column_play_button_style_context.add_class ("image-button");
            column_play_button.set_image (new Gtk.Image.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.SMALL_TOOLBAR));

            var column_button = new Gtk.Button ();
            column_button.can_focus = false;
            column_button.halign = Gtk.Align.END;
            column_button.valign = Gtk.Align.CENTER;
            column_button.width_request = 42;
            column_button.height_request = 42;
            var column_button_style_context = column_button.get_style_context ();
            column_button_style_context.add_class ("tt-button");
            column_button_style_context.add_class ("image-button");
            column_button.set_image (new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR));

            column_button.clicked.connect (() => {
                add_task (column_entry.text, timer ());
                column_entry.text = "";
            });

            this.row_spacing = 6;
            this.attach (column_play_button, 0, 0, 1, 2);
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

        // TODO: Think about this
        public string timer () {
            return "0";
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
