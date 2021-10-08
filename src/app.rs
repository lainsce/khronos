use log::{debug, info};
use glib::clone;
use gtk::prelude::*;
use gtk::subclass::prelude::*;
use adw::subclass::prelude::*;
use gtk::{gdk, gio, glib};
use gtk_macros::action;

use crate::config;
use crate::ui::window::KhronosMainWindow;
use crate::ui::prefs::KhronosPrefs;
use crate::ui::about;


mod imp {
    use super::*;
    use once_cell::sync::OnceCell;
    use glib::WeakRef;

    #[derive(Default)]
    pub struct KhronosApplication {
        pub window: OnceCell<WeakRef<KhronosMainWindow>>,
    }

    #[glib::object_subclass]
    impl ObjectSubclass for KhronosApplication {
        const NAME: &'static str = "KhronosApplication";
        type Type = super::KhronosApplication;
        type ParentType = adw::Application;
    }

    impl ObjectImpl for KhronosApplication {
        fn constructed(&self, obj: &Self::Type) {
            self.parent_constructed(obj);
        }
    }

    impl ApplicationImpl for KhronosApplication {
        fn startup(&self, app: &Self::Type) {
            debug!("Application::startup");
            self.parent_startup(app);
            gtk::Window::set_default_icon_name(config::APP_ID);
        }

        fn activate(&self, app: &Self::Type) {
            debug!("Application::activate");
            if let Some(weak_window) = self.window.get() {
                let window = weak_window.upgrade().unwrap();
                window.present();
                info!("Application window presented.");
                return;
            }

            let window = app.create_window();
            let _ = self.window.set(window.downgrade());

            app.setup_gactions(&window);
        }
    }

    impl AdwApplicationImpl for KhronosApplication {}
    impl GtkApplicationImpl for KhronosApplication {}
}

glib::wrapper! {
    pub struct KhronosApplication(ObjectSubclass<imp::KhronosApplication>)
        @extends adw::Application, gio::Application, gtk::Application,
        @implements gio::ActionMap, gio::ActionGroup;
}

impl KhronosApplication {
    pub fn run() {
        info!("{} ({})", config::NAME, config::APP_ID);
        info!("Version: {} ({})", config::VERSION, config::PROFILE);

        let app = glib::Object::new::<KhronosApplication>(&[
            ("application-id", &Some(config::APP_ID)),
            ("flags", &gio::ApplicationFlags::empty()),
            ("resource-base-path", &Some("/io/github/lainsce/Khronos/")),
        ])
        .unwrap();

        app.run();
    }

    pub fn imp(&self) -> &imp::KhronosApplication {
        imp::KhronosApplication::from_instance(self)
    }

    fn create_window(&self) -> KhronosMainWindow {
        let window = KhronosMainWindow::new(self.clone());
        window.present();
        window
    }

    fn setup_gactions(&self, window: &KhronosMainWindow) {
        action!(
            window,
            "about",
            clone!(@weak window => move |_, _| {
                about::show_about_dialog(&window);
            })
        );

        action!(
            window,
            "prefs",
            clone!(@weak window => move |_, _| {
                KhronosPrefs::new(&window);
            })
        );
        self.set_accels_for_action("win.prefs", &["<primary>comma"]);

        let window = KhronosMainWindow::new(self.clone());

        action!(
            self,
            "quit",
            clone!(@weak self as this => move |_, _| {
                this.quit();
            })
        );
        self.set_accels_for_action("app.quit", &["<primary>q"]);
    }
}

