namespace Khronos {
    public class TaskEventBox : Gtk.EventBox {
        public MainWindow win;
        public TaskBox tb;
        public Gtk.Button app_button;
        public Gtk.Button task_delete_button;
        public Gtk.Revealer revealer;
        private int uid;
        private static int uid_counter;

        public bool show_button = true;
        public bool show_popover = true;
        public TaskEventBox evbox;
        public Gtk.Label task_label;
        public Gtk.Label task_time_label;
        public Gtk.Label task_date_label;

        public signal void delete_requested ();

        public TaskEventBox (MainWindow win, TaskBox tb) {
            this.win = win;
            this.uid = uid_counter++;
            this.tb = tb;
            this.margin = 6;

            win.tm.save_notes ();

            Khronos.Application.gsettings.changed.connect (() => {
                win.tm.save_notes ();
            });

            task_label = new Gtk.Label ("");
            task_label.halign = Gtk.Align.START;
            task_label.wrap = true;
            task_label.hexpand = true;
            task_label.label = tb.name;

            task_time_label = new Gtk.Label ("");
            task_time_label.use_markup = true;
            task_time_label.halign = Gtk.Align.START;
            task_time_label.label = tb.time;

            task_date_label = new Gtk.Label ("");
            task_date_label.use_markup = true;
            task_date_label.halign = Gtk.Align.START;
            task_date_label.label = tb.date;

            var task_box = new Gtk.Grid ();
            task_box.row_homogeneous = true;
            task_box.events |= Gdk.EventMask.BUTTON_PRESS_MASK &
                               Gdk.EventMask.BUTTON_RELEASE_MASK;
            task_box.attach (task_label, 0, 0);
            task_box.attach (task_time_label, 0, 1);
            task_box.attach (task_date_label, 0, 2);

            task_delete_button = new Gtk.Button();
            task_delete_button.events |= Gdk.EventMask.BUTTON_PRESS_MASK &
                                         Gdk.EventMask.BUTTON_RELEASE_MASK;
            var task_delete_button_c = task_delete_button.get_style_context ();
            task_delete_button_c.add_class ("flat");
            task_delete_button_c.add_class ("icon-shadow");
            task_delete_button.has_tooltip = true;
            task_delete_button.vexpand = false;
            task_delete_button.valign = Gtk.Align.CENTER;
            task_delete_button.set_image (new Gtk.Image.from_icon_name (
                                             "edit-delete-symbolic",
                                             Gtk.IconSize.BUTTON
                                          ));
            task_delete_button.tooltip_text = (_("Delete Task"));

            var task_buttons_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
            task_buttons_box.pack_start (task_delete_button, false, true, 0);

            revealer = new Gtk.Revealer ();
            revealer.events |= Gdk.EventMask.ENTER_NOTIFY_MASK &
                               Gdk.EventMask.LEAVE_NOTIFY_MASK &
                               Gdk.EventMask.BUTTON_PRESS_MASK &
                               Gdk.EventMask.BUTTON_RELEASE_MASK;
            revealer.set_transition_duration (100);
            revealer.set_transition_type (Gtk.RevealerTransitionType.CROSSFADE);
            revealer.halign = Gtk.Align.START;
            revealer.valign = Gtk.Align.CENTER;
            revealer.add (task_buttons_box);

            var grid = new Gtk.Grid ();
            grid.events |= Gdk.EventMask.ENTER_NOTIFY_MASK &
                               Gdk.EventMask.LEAVE_NOTIFY_MASK &
                               Gdk.EventMask.BUTTON_PRESS_MASK &
                               Gdk.EventMask.BUTTON_RELEASE_MASK;
            grid.attach (task_box, 0, 0);
            grid.attach (revealer, 1, 0);

            this.add (grid);

            task_delete_button.clicked.connect (() => {
                delete_requested ();
            });

            this.enter_notify_event.connect ((event) => {
                revealer.set_reveal_child (this.show_button);
                return false;
            });

            this.leave_notify_event.connect ((event) => {
    	        revealer.set_reveal_child (this.show_button);
    	        return false;
            });

            revealer.leave_notify_event.connect ((event) => {
                revealer.set_reveal_child (false);
	            return false;
            });

            task_delete_button.enter_notify_event.connect ((event) => {
                revealer.set_reveal_child (this.show_button);
                return false;
            });
        }
    }
}
