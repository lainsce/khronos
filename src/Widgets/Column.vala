namespace Khronos {
    public class DayColumn : Gtk.Grid {
        private MainWindow win;
        public DayColumnListBox column;

        public DayColumn (int day, MainWindow win) {
            this.win = win;
            this.set_size_request (200,-1);
            this.column_homogeneous =true;

            var rec_label = new Gtk.Label (null);
            rec_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
            rec_label.tooltip_text = _("Logged tasks will end up here.");
            rec_label.use_markup = true;
            rec_label.halign = Gtk.Align.START;
            rec_label.margin_start = 9;
            rec_label.label = _("LOGS");

            column = new DayColumnListBox (day, win);

            this.row_spacing = 6;
            this.attach (rec_label, 0, 0);
            this.attach (column, 0, 1);

            var column_style_context = this.get_style_context ();
            column_style_context.add_class ("tt-column");

            this.show_all ();
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
