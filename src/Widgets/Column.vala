namespace Khronos {
    public class DayColumn : Gtk.Grid {
        private MainWindow win;
        public DayColumnListBox column;

        public DayColumn (int day, MainWindow win) {
            this.win = win;
            this.column_homogeneous = true;

            var title_label =new Gtk.Label (_("Logs"));
            title_label.get_style_context ().add_class ("title-1");
            title_label.halign = Gtk.Align.START;

            column = new DayColumnListBox (day, win);

            this.row_spacing = 12;
            this.margin = 24;
            this.attach (title_label, 0, 0);
            this.attach (column, 0, 1);
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
