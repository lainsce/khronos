namespace Khronos {
    public class TaskBox : Hdy.ActionRow {
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

            set_title (name);
            set_subtitle ("%s\n%s".printf(time.replace("<span font_features='tnum'>", "").replace("</span>", ""), date.replace("<span font_features='tnum'>", "").replace("</span>", "")));

            var task_delete_button = new Gtk.Button();
            task_delete_button.has_tooltip = true;
            task_delete_button.vexpand = false;
            task_delete_button.valign = Gtk.Align.CENTER;
            task_delete_button.set_image (new Gtk.Image.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.BUTTON));
            task_delete_button.get_style_context ().add_class ("circular-button");
            task_delete_button.get_style_context ().add_class ("flat");
            task_delete_button.tooltip_text = (_("Delete Task"));
            task_delete_button.clicked.connect (() => {
                this.destroy ();
                win.tm.save_notes ();
            });

            this.add (task_delete_button);
            this.hexpand = false;
            this.show_all ();
            this.selectable = false;
        }
    }
}
