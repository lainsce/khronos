namespace Khronos {
    public class Log : Object {
        public string name { get; set; }
        public string timedate { get; set; }
    }

    [GtkTemplate (ui = "/io/github/lainsce/Khronos/logrow.ui")]
    public class LogRow : Adw.ActionRow {
        [GtkChild]
        public unowned Gtk.Button delete_button;

        public unowned Log log { get; construct; }
        public LogRow (Log? log) {
            Object (log: log);
        }
        construct {
            this.title = log.name;
            this.subtitle = log.timedate;
        }
    }
}
