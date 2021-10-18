use glib::Object;
use gtk::glib;
use gtk::CompositeTemplate;
use adw::*;

use crate::ui::log::LogTask;

glib::wrapper! {
    pub struct KhronosLogRow(ObjectSubclass<imp::KhronosLogRow>)
        @extends adw::ActionRow, adw::PreferencesRow, gtk::Widget,
        @implements gtk::Accessible, gtk::Actionable, gtk::Buildable, gtk::ConstraintTarget;
}

mod imp {
    use super::*;
    use gtk::glib;
    use gtk::subclass::prelude::*;
    use adw::subclass::prelude::*;
    use adw::prelude::*;
    use std::cell::Cell;

    // Object holding the state
    #[derive(CompositeTemplate)]
    #[template(resource = "/io/github/lainsce/Khronos/logrow.ui")]
    pub struct KhronosLogRow {
        item: LogTask,
    }

    // The central trait for subclassing a GObject
    #[glib::object_subclass]
    impl ObjectSubclass for KhronosLogRow {
        const NAME: &'static str = "KhronosLogRow";
        type Type = super::KhronosLogRow;
        type ParentType = adw::ActionRow;
    }

    // Trait shared by all GObjects
    impl ObjectImpl for KhronosLogRow {
        fn constructed(&self, obj: &Self::Type) {
            self.parent_constructed(obj);
            obj.set_title(&self.item.name.get().to_string());
            obj.set_subtitle(&self.item.timedate.get().to_string());
        }
    }

    // Trait shared by all widgets
    impl WidgetImpl for KhronosLogRow {}

    // Trait shared by all actionrows
    impl ListBoxRowImpl for KhronosLogRow {}
    impl PreferencesRowImpl for KhronosLogRow {}
    impl ActionRowImpl for KhronosLogRow {}
}

impl KhronosLogRow {
    pub fn new(item: LogTask) -> Self {
        Object::new(&[]).expect("Failed to create `KhronosLogRow`.")
        self.item = item;
    }
}
