/*
* Copyright (C) 2017-2022 Lains
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
public class Khronos.TagHolder : Gtk.Widget {
    public List<Gtk.Widget> children;

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }
    construct {
        ((Gtk.BoxLayout) layout_manager).spacing = 6;
    }

    public void append (Gtk.Widget child) {
        child.set_parent (this);
        children.append(child);
    }

    public override void dispose () {
        foreach (var child in children) {
            child.unparent ();
        }

        base.dispose ();
    }

    public void remove (Gtk.Widget child) {
        if (children.find (child) == null) {
            return;
        }

        child.unparent ();
    }
}
