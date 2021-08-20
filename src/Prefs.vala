namespace Khronos {
    [GtkTemplate (ui = "/io/github/lainsce/Khronos/prefs.ui")]
    public class Prefs : Adw.PreferencesWindow {
        public int delay { get; set; }
        public bool active { get; set; }

        [GtkChild]
        public unowned Gtk.Switch darkmode;

        [GtkChild]
        public unowned Gtk.Scale delay_scale;

        construct {
            delay_scale.add_mark (30, Gtk.PositionType.BOTTOM, null);
        }
    }
}

