namespace Khronos {
    public class DayColumn : Hdy.PreferencesGroup {
        private MainWindow win;

        public DayColumn (MainWindow win) {
            this.win = win;
            this.margin = 24;
            set_title (_("Logs"));
            this.show_all ();
        }

        public Gee.ArrayList<TaskBox> get_tasks () {
            var tasks = new Gee.ArrayList<TaskBox> ();
            foreach (Gtk.Widget item in this.get_children ()) {
	            tasks.add ((TaskBox)item);
            }
            return tasks;
        }
    }
}
