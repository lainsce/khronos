// We don't want default methods for all GObject types
#![allow(clippy::new_without_default)]
#![warn(clippy::await_holding_refcell_ref)]
#![warn(clippy::cast_lossless)]
#![warn(clippy::comparison_to_empty)]
#![warn(clippy::manual_find_map)]
#![warn(clippy::map_unwrap_or)]
#![warn(clippy::redundant_closure_for_method_calls)]
#![warn(clippy::struct_excessive_bools)]
#![warn(clippy::unnecessary_unwrap)]
#![warn(clippy::wildcard_imports)]
#![warn(clippy::trivially_copy_pass_by_ref)]
#![warn(clippy::option_if_let_else)]
//

use gettextrs::*;
use gtk::{gio, glib};

mod app;
mod config;
mod ui;
mod i18n;

use crate::app::KhronosApplication;

fn main() {
    // Initialize GTK
    gtk::init().expect("Failed to initialize GTK.");

    // Prepare i18n
    gettextrs::setlocale(LocaleCategory::LcAll, "");
    gettextrs::bindtextdomain(config::GETTEXT_PACKAGE, config::LOCALEDIR).expect("Unable to bind the text domain");
    gettextrs::textdomain(config::GETTEXT_PACKAGE).expect("Unable to switch to the text domain");

    let res = gio::Resource::load(config::RESOURCES_FILE).expect("Could not load gresource file");
    gio::resources_register(&res);

    glib::set_application_name(config::NAME);
    glib::set_prgname(Some("io.github.lainsce.Khronos"));


    // Start application
    KhronosApplication::run();
}

