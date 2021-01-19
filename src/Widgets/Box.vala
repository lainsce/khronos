namespace Khronos {
    public class TaskBox : Gtk.ListBoxRow {
        private MainWindow win;

        public new string name;
        public string time;
        public string date;

        private int uid;
        private static int uid_counter;

        public TaskBox (MainWindow win, string name, string time, string date) {
            this.win = win;
            this.uid = uid_counter++;
            this.name = name;
            this.time = time;
            this.date = date;

            var evbox = new TaskEventBox (this.win, this);

            var task_grid = new Gtk.Grid ();
            task_grid.hexpand = false;
            task_grid.row_spacing = 6;
            task_grid.row_homogeneous = true;
            task_grid.margin_start = 4;
            task_grid.attach (evbox, 0, 0, 1, 2);

            evbox.delete_requested.connect (() => {
                this.destroy ();
                win.tm.save_notes ();
            });

            this.add (task_grid);
            this.hexpand = false;
            this.show_all ();
            this.get_style_context ().add_class ("tt-box");
        }
    }
}
