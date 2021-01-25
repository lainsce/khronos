namespace Khronos {
    [GtkTemplate (ui = "/io/github/lainsce/Khronos/prefs.ui")]
    public class Prefs : Hdy.PreferencesWindow {
        public int delay { get; set; }
        public bool active { get; set; }

        [GtkChild]
        public Gtk.Switch darkmode;
    }
}

