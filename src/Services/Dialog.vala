/*
 * Copyright (C) 2020-2021 Lains
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
namespace Khronos.Dialog {
    public unowned MainWindow win;
    public async string display_save_dialog () {
        var chooser = new Gtk.FileChooserNative (null, win, Gtk.FileChooserAction.SAVE, null, null);
        chooser.set_transient_for(win);
        var filter1 = new Gtk.FileFilter ();
        filter1.set_filter_name (_("CSV files"));
        filter1.add_pattern ("*.csv");
        chooser.add_filter (filter1);
        var filter = new Gtk.FileFilter ();
        filter.set_filter_name (_("All files"));
        filter.add_pattern ("*");
        chooser.add_filter (filter);

        var response = yield run_dialog_async (chooser);

        if (response == Gtk.ResponseType.ACCEPT) {

            yield;
            return chooser.get_file ().get_path ();
        }

        yield;
        return "";
    }

    private async Gtk.ResponseType run_dialog_async (Gtk.FileChooserNative dialog) {
		var response = Gtk.ResponseType.CANCEL;

		dialog.response.connect (r => {
			response = (Gtk.ResponseType) r;

			run_dialog_async.callback ();
		});

		dialog.show ();

		yield;
		return response;
	}

}
