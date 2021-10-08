use adw::subclass::prelude::*;
use gtk::subclass::prelude::*;
use gtk::CompositeTemplate;
use gtk::{gio, glib, prelude::*};
use glib::clone;

use crate::config;
use crate::app::KhronosApplication;
use crate::ui::log::LogTask;

mod imp {
    use super::*;
    use glib::subclass;
    use adw::subclass::application_window::AdwApplicationWindowImpl;

    #[derive(CompositeTemplate)]
    #[template(resource = "/io/github/lainsce/Khronos/main_window.ui")]
    pub struct KhronosMainWindow {
        #[template_child]
        pub window: TemplateChild<adw::ApplicationWindow>,
        #[template_child]
        pub win_switcher: TemplateChild<adw::ViewSwitcher>,
        #[template_child]
        pub win_stack: TemplateChild<adw::ViewStack>,
        #[template_child]
        pub trash_button: TemplateChild<gtk::Button>,
        #[template_child]
        pub column_time_label: TemplateChild<gtk::Label>,
        #[template_child]
        pub column_entry: TemplateChild<gtk::Entry>,
        #[template_child]
        pub timer_button: TemplateChild<gtk::Button>,
        #[template_child]
        pub add_log_button: TemplateChild<gtk::Button>,
        #[template_child]
        pub column: TemplateChild<gtk::ListBox>,
        #[template_child]
        pub menu_button: TemplateChild<gtk::MenuButton>,
        pub settings: gio::Settings,
    }

    impl Default for KhronosMainWindow {
        fn default() -> Self {
            let settings = gio::Settings::new(config::APP_ID);

            KhronosMainWindow {
                window: TemplateChild::default(),
                win_switcher: TemplateChild::default(),
                win_stack: TemplateChild::default(),
                trash_button: TemplateChild::default(),
                column_time_label: TemplateChild::default(),
                column_entry: TemplateChild::default(),
                timer_button: TemplateChild::default(),
                add_log_button: TemplateChild::default(),
                column: TemplateChild::default(),
                menu_button: TemplateChild::default(),
                settings,
            }
        }
    }

    #[glib::object_subclass]
    impl ObjectSubclass for KhronosMainWindow {
        const NAME: &'static str = "KhronosMainWindow";
        type ParentType = adw::ApplicationWindow;
        type Type = super::KhronosMainWindow;

        fn class_init(klass: &mut Self::Class) {
            Self::bind_template(klass);
        }

        fn instance_init(obj: &subclass::InitializingObject<Self>) {
            obj.init_template();
        }
    }

    impl ObjectImpl for KhronosMainWindow {
        fn constructed(&self, obj: &Self::Type) {
            self.parent_constructed(obj);

            obj.update_color_scheme(self.settings.boolean("dark-mode"));

            self.settings.connect_changed (
                None,
                clone!(@weak obj => move |settings, key| {
                    match key {
                        "dark-mode" => {
                            match settings.boolean(key) {
                                    true => obj.update_color_scheme(true),
                                    false => obj.update_color_scheme(false),
                            }
                        }
                        _ => ()
                    }
                }),
            );

            let hrs = 0; let min = 0; let sec = 0;
            let timer_id = 0;
            let id1 = 0; // 30min.
            let id2 = 0; // 1h.
            let id3 = 0; // 1h30min.
            let id4 = 0; // 2h.
            let id5 = 0; // 2h30min.

            let dt = glib::DateTime::new_now_local ();
            let model = gio::ListStore::new(LogTask::static_type());

            //self.column.bind_model (Some(&liststore), make_widgets (item));

            // Devel Profile
            if config::PROFILE == "Devel" {
                obj.add_css_class("devel");
            }

            self.column_time_label.set_label (&format!("{:02}∶{:02}∶{:02}", hrs, min, sec));

            self.trash_button.set_visible (false);
        }
    }

    impl WidgetImpl for KhronosMainWindow {}

    impl WindowImpl for KhronosMainWindow {
        fn close_request(&self, window: &Self::Type) -> glib::signal::Inhibit {
            self.parent_close_request(window)
        }
    }

    impl ApplicationWindowImpl for KhronosMainWindow {}
    impl AdwApplicationWindowImpl for KhronosMainWindow {}
}

// Wrap KhronosMainWindow into a usable gtk-rs object
glib::wrapper! {
    pub struct KhronosMainWindow(
        ObjectSubclass<imp::KhronosMainWindow>)
        @extends gtk::Widget, gtk::Window, adw::Window, gtk::Application, adw::Application,
                 gtk::ApplicationWindow, adw::ApplicationWindow,
        @implements gio::ActionGroup, gio::ActionMap, gtk::Accessible, gtk::Buildable,
                    gtk::ConstraintTarget, gtk::Native, gtk::Root, gtk::ShortcutManager;
}

// KhronosMainWindow implementation itself
impl KhronosMainWindow {
    pub fn new(app: KhronosApplication) -> Self {
        // Create new GObject and downcast it into KhronosMainWindow
        let window = glib::Object::new::<Self>(&[]).unwrap();
        app.add_window(&window);

        window
    }

    pub fn imp(&self) -> &imp::KhronosMainWindow {
        imp::KhronosMainWindow::from_instance(self)
    }

    fn update_color_scheme(&self, b: bool) {
        let self_ = self.imp();
        let manager = adw::StyleManager::default().unwrap();
        if !manager.system_supports_color_schemes() {
            let color_scheme = if b {
                adw::ColorScheme::PreferDark
            } else {
                adw::ColorScheme::PreferLight
            };
            manager.set_color_scheme(color_scheme);
        }
    }
}

