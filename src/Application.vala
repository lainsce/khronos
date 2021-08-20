/*
* Copyright (c) 2020-2021 Lains
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
*/
namespace Khronos {
    public class Application : Gtk.Application {
        public static unowned MainWindow win = null;
        public static GLib.Settings gsettings;

        public Application () {
            Object (
                flags: ApplicationFlags.FLAGS_NONE,
                application_id: "io.github.lainsce.Khronos"
            );
        }

        static construct {
            gsettings = new GLib.Settings ("io.github.lainsce.Khronos");
        }

        construct {
            Intl.setlocale (LocaleCategory.ALL, "");
            Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
            Intl.textdomain (Config.GETTEXT_PACKAGE);
        }

        protected override void activate () {
            var w = new MainWindow (this);
            win = w;
        }

        public static int main (string[] args) {
            var app = new Khronos.Application ();
            int status = app.run (args);
		    return status;
        }
    }
}
