use crate::config;
use crate::i18n::*;
use gtk::prelude::*;

use crate::ui::window::KhronosMainWindow;

pub fn show_about_dialog(window: &KhronosMainWindow) {
    let version: String = match config::PROFILE {
        "devel" => format!("{} \n(Development)", config::VERSION),
        _ => format!("{}", config::VERSION),
    };

    let dialog = gtk::AboutDialog::new();
    dialog.set_program_name(Some(config::NAME));
    dialog.set_logo_icon_name(Some(config::APP_ID));
    dialog.set_comments(Some(&i18n("Log the time it took to do tasks")));
    dialog.set_copyright(Some("© 2017-2021 Paulo \"Lains\" Galardi"));
    dialog.set_website(Some("https://github.com/lainsce/khronos"));
    dialog.set_translator_credits(Some(&i18n("translator-credits")));
    dialog.set_license_type(gtk::License::Gpl30);
    dialog.set_version(Some(version.as_str()));
    dialog.set_transient_for(Some(window));
    dialog.set_modal(true);
    dialog.set_authors(&["Paulo \"Lains\" Galardi"]);

    dialog.show();
}

