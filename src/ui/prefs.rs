use adw::subclass::prelude::*;
use gtk::subclass::prelude::*;
use gtk::{CompositeTemplate, gio, gio::SettingsBindFlags, glib, prelude::*, subclass::window::WindowImplExt};
use glib::{subclass, Value};
use once_cell::sync::Lazy;
use std::cell::Cell;

use crate::ui::window::KhronosMainWindow;
use crate::config;

mod imp {
    use super::*;

    #[derive(CompositeTemplate)]
    #[template(resource = "/io/github/lainsce/Khronos/prefs.ui")]
    pub struct KhronosPrefs {
        pub delay: Cell<i32>,
        pub settings: gio::Settings,

        #[template_child]
        pub dark_mode_button: TemplateChild<gtk::Switch>,
        #[template_child]
        pub delay_scale: TemplateChild<gtk::Scale>,
    }

    impl Default for KhronosPrefs {
        fn default() -> Self {
            let settings = gio::Settings::new(config::APP_ID);

            let delay = Cell::new(0);
            delay.set(settings.int("notification-delay") / 60);

            KhronosPrefs {
                delay,
                settings,
                dark_mode_button: TemplateChild::default(),
                delay_scale: TemplateChild::default(),
            }
        }
    }

    #[glib::object_subclass]
    impl ObjectSubclass for KhronosPrefs {
        const NAME: &'static str = "KhronosPrefs";
        type ParentType = adw::PreferencesWindow;
        type Type = super::KhronosPrefs;

        fn class_init(klass: &mut Self::Class) {
            Self::bind_template(klass);
        }

        fn instance_init(obj: &subclass::InitializingObject<Self>) {
            obj.init_template();
        }
    }

    impl ObjectImpl for KhronosPrefs {
        fn properties() -> &'static [glib::ParamSpec] {
            static PROPERTIES: Lazy<Vec<glib::ParamSpec>> = Lazy::new(|| {
                vec![glib::ParamSpec::new_int(
                    "delay","delay","Notification delay",i32::MIN,i32::MAX,0,glib::ParamFlags::READWRITE,
                )]
            });
            PROPERTIES.as_ref()
        }

        fn set_property(&self, _obj: &Self::Type, _id: usize, value: &Value, pspec: &glib::ParamSpec) {
            match pspec.name() {
                "delay" => {
                    let input_delay = value.get().expect("The value needs to be of type `i32`.");
                    self.delay.replace(input_delay);
                }
                _ => unimplemented!(),
            }
        }

        fn property(&self, _obj: &Self::Type, _id: usize, pspec: &glib::ParamSpec) -> Value {
            match pspec.name() {
                "delay" => self.delay.get().to_value(),
                _ => unimplemented!(),
            }
        }

        fn constructed(&self, obj: &Self::Type) {
            self.parent_constructed(obj);

            self.delay_scale.add_mark (30.0, gtk::PositionType::Bottom, Some(""));

            self.settings
                .bind("dark-mode", &self.dark_mode_button.get(), "state")
                .flags(SettingsBindFlags::DEFAULT)
                .build();
        }
    }

    impl WindowImpl for KhronosPrefs {
        fn close_request(&self, window: &Self::Type) -> glib::signal::Inhibit {
            self.parent_close_request(window)
        }
    }

    impl AdwWindowImpl for KhronosPrefs {}
    impl PreferencesWindowImpl for KhronosPrefs {}
    impl WidgetImpl for KhronosPrefs {}
}

glib::wrapper! {
    pub struct KhronosPrefs(
        ObjectSubclass<imp::KhronosPrefs>)
        @extends gtk::Widget, gtk::Window, gtk::Dialog, adw::PreferencesWindow,
        @implements gio::ActionMap, gio::ActionGroup;
}

impl KhronosPrefs {
    pub fn new(window: &KhronosMainWindow) -> Self {
        let prefs = glib::Object::new::<KhronosPrefs>(&[]).unwrap();
        prefs.set_transient_for(Some(window));
        prefs.set_modal(true);
        prefs.show();
        prefs
    }
}

