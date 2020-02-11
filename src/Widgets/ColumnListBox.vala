namespace Khronos {
    public class DayColumnListBox : Gtk.ListBox {
        private MainWindow win;

        private const Gtk.TargetEntry[] targetEntries = {
            {"TASKBOX", Gtk.TargetFlags.SAME_APP, 0}
        };

        public DayColumnListBox (int day, MainWindow win) {
            this.win = win;
            this.hexpand = true;
            this.vexpand = true;
            this.activate_on_single_click = false;
            this.selection_mode = Gtk.SelectionMode.SINGLE;
            this.set_sort_func ((row1, row2) => {
                string task1 = ((TaskBox) row1).time;
                string task2 = ((TaskBox) row2).time;

                int int1 = int.parse(task1);
                int int2 = int.parse(task2);

                unichar str1 = task1.get_char (task1.index_of_nth_char (0));
                unichar str2 = task2.get_char (task2.index_of_nth_char (0));

                if (str1.tolower () != 'a' || str2.tolower () != 'a') {
                    return strcmp (task1.ascii_down (), task2.ascii_down ());
                } else if (int1 > int2) {
                    return task1.ascii_down ().collate (task2.ascii_down ());
                } else {
                    return 0;
                }
            });

            this.build_drag_and_drop ();

            var column_style_context = this.get_style_context ();
            column_style_context.add_class ("tt-column");

            var no_tasks = new Gtk.Label (_("No tasks…"));
            no_tasks.halign = Gtk.Align.CENTER;
            var no_tasks_style_context = no_tasks.get_style_context ();
            no_tasks_style_context.add_class ("h2");
            no_tasks.sensitive = false;
            no_tasks.margin = 12;
            no_tasks.show_all ();
            this.set_placeholder (no_tasks);
        }

        private void build_drag_and_drop () {
            Gtk.drag_dest_set (this, Gtk.DestDefaults.ALL, targetEntries, Gdk.DragAction.MOVE);

            this.drag_data_received.connect (on_drag_data_received);
        }

        private void on_drag_data_received (Gdk.DragContext context, int x, int y, Gtk.SelectionData selection_data, uint target_type, uint time) {
            TaskBox target;
            Gtk.Widget row;
            TaskBox source;
            int newPos;
            Gtk.Allocation alloc;

            target = (TaskBox) this.get_row_at_y (y);
            target.get_allocation (out alloc);
            row = ((Gtk.Widget[]) selection_data.get_data ())[0];
            source = (TaskBox) row;

            int last_index = (int) this.get_children ().length;

            if (target == null) {
                newPos = -1;
            } else {
                newPos = last_index-1;
            }

            source.get_parent ().remove (source);
            this.insert (source, newPos);
            source.show_all ();

            win.tm.save_notes ();
        }
    }
}