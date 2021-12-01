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
*/

namespace Khronos {
    public class MigrationManager {
        public unowned MainWindow win = null;
        public unowned Json.Builder builder;
        private string app_dir = Environment.get_user_data_dir () + "/io.github.lainsce.Khronos";
        private string file_name;

        public MigrationManager (MainWindow win) {
            this.win = win;
            file_name = this.app_dir + "/saved_logged_tasks.json";
        }

        public void load_from_file() {
            try {
                var file = File.new_for_path(file_name);
                var json_string = "";
                if (file.query_exists()) {
                    GLib.FileUtils.get_contents (file.get_path (), out json_string);
                    var parser = new Json.Parser();
                    parser.load_from_data(json_string);
                    var root = parser.get_root();
                    var array = root.get_array();
                    foreach (var tasks in array.get_elements()) {
                        var task = tasks.get_array ();
                        string name = task.get_string_element(0);
                        string timedate = task.get_string_element(1);

                        win.add_task (Uuid.string_random (), name, timedate);
                    }
                }
            } catch (Error e) {
                warning ("Failed to load file: %s\n", e.message);
            }
        }
    }
}
