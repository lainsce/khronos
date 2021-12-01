/*
* Copyright (C) 2017-2021 Lains
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
[GtkTemplate (ui = "/io/github/lainsce/Khronos/logrowcontent.ui")]
public class Khronos.LogRowContent : Adw.Bin {
    public signal void clicked ();
    public LogViewModel? logs {get; set;}

    [GtkChild]
    public unowned Gtk.Label log_label;
    [GtkChild]
    public unowned Gtk.Label log2_label;

    Binding? text_binding;
    Binding? text2_binding;

    Log? _log;
    public Log? log {
        get { return _log; }
        set {
            if (value == _log)
                return;

            text_binding?.unbind ();
            text2_binding?.unbind ();

            _log = value;

            text_binding = _log?.bind_property (
                "name", log_label, "label", SYNC_CREATE|BIDIRECTIONAL);
            text2_binding = _log?.bind_property (
                "timedate", log2_label, "label", SYNC_CREATE|BIDIRECTIONAL);
        }
    }

    construct {
    }

    [GtkCallback]
    void on_delete_button_clicked () {
        ((LogListView)MiscUtils.find_ancestor_of_type<LogListView>(this)).log_removal_requested (log);
    }
}
