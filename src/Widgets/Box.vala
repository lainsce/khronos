namespace Khronos {
    public class Log : Object {
        public string name { get; set; }
        public string timedate { get; set; }
    }

    [GtkTemplate (ui = "/io/github/lainsce/Khronos/logrow.ui")]
    public class LogRow : Gtk.ListBoxRow {
        public Log log { get; construct; }
        public LogRow (Log log) {
            Object (log: log);

            this.get_style_context ().add_class ("kh-row");
        }
    }
}
