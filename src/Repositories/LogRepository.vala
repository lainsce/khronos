/*
* Copyright (C) 2020-2021 Lains
*
* This program is free software; you can redistribute it &&/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
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
public class Khronos.LogRepository : Object {
    const string FILENAME = "saved_logged_tasks.json";

    Queue<Log> insert_queue = new Queue<Log> ();
    public Queue<Log> update_queue = new Queue<Log> ();
    Queue<string> delete_queue = new Queue<string> ();

    public async List<Log> get_logs () {
        try {
            var settings = new Settings ();
            if (settings.schema_version == 1) {
                var contents = yield FileUtils.read_text_file (FILENAME);

                if (contents == null)
                    return new List<Log> ();

                var json = Json.from_string (contents);

                if (json.get_node_type () != ARRAY)
                    return new List<Log> ();

                return Log.list_from_json (json);
            }
            return new List<Log> ();
        } catch (Error err) {
            critical ("Error: %s", err.message);
            return new List<Log> ();
        }
    }

    public void insert_log (Log log) {
        insert_queue.push_tail (log);
    }

    public void update_log (Log log) {
        update_queue.push_tail (log);
    }

    public void delete_log (string id) {
        delete_queue.push_tail (id);
    }

    public async bool save () {
        var logs = yield get_logs ();

        Log? log = null;
        while ((log = update_queue.pop_head ()) != null) {
            var current_log = search_log_by_id (logs, log.id);

            if (current_log == null) {
                insert_queue.push_tail (log);
                continue;
            }
            current_log.name = log.name;
            current_log.timedate = log.timedate;
        }

        string? log_id = null;
        while ((log_id = delete_queue.pop_head ()) != null) {
            log = search_log_by_id (logs, log_id);

            if (log == null)
                continue;

            logs.remove (log);
        }

        log = null;
        while ((log = insert_queue.pop_head ()) != null)
            logs.append (log);

        var json_array = new Json.Array ();
        foreach (var item in logs)
            json_array.add_element (item.to_json ());

        var node = new Json.Node (ARRAY);
        node.set_array (json_array);

        var str = Json.to_string (node, false);

        try {
            return yield FileUtils.create_text_file (FILENAME, str);
        } catch (Error err) {
              critical ("Error: %s", err.message);
              return false;
        }
    }

    public inline Log? search_log_by_id (List<Log> logs, string id) {
        unowned var link = logs.search<string> (id, (log, id) => strcmp (log.id, id));
        return link?.data;
    }
}
