use gtk::prelude::*;
use gtk::subclass::prelude::*;
use gtk::{glib};
use glib::{Object, Value};
use once_cell::sync::Lazy;

#[derive(Default)]
pub struct LogTaskData {}

glib::wrapper! {
    pub struct LogTask(ObjectSubclass<imp::LogTask>);
}

mod imp {
    use super::*;

    // Object holding the state
    #[derive(Default)]
    pub struct LogTask {
        pub name: String,
        pub timedate: String,
    }

    // The central trait for subclassing a GObject
    #[glib::object_subclass]
    impl ObjectSubclass for LogTask {
        const NAME: &'static str = "LogTask";
        type Type = super::LogTask;
        type ParentType = glib::Object;
    }

    impl ObjectImpl for LogTask {
        fn properties() -> &'static [glib::ParamSpec] {
            static PROPERTIES: Lazy<Vec<glib::ParamSpec>> = Lazy::new(|| {
                vec![glib::ParamSpec::new_string(
                    "name","name","Log Name",Some(""),glib::ParamFlags::READWRITE,
                ),
                glib::ParamSpec::new_string(
                    "timedate","timedate","Log Time & Date",Some(""),glib::ParamFlags::READWRITE,
                )]
            });
            PROPERTIES.as_ref()
        }

        fn set_property(&self, _obj: &Self::Type, _id: usize, value: &Value, pspec: &glib::ParamSpec) {
            match pspec.name() {
                "name" => {
                    let name_io = value.get().expect("The value needs to be of type `String`.");
                    self.name.replace("", name_io);
                },
                "timedate" => {
                    let timedate_io = value.get().expect("The value needs to be of type `String`.");
                    self.timedate.replace("", timedate_io);
                },
                _ => unimplemented!(),
            }
        }

        fn property(&self, _obj: &Self::Type, _id: usize, pspec: &glib::ParamSpec) -> Value {
            match pspec.name() {
                "name" => self.name.to_value(),
                "timedate" => self.timedate.to_value(),
                _ => unimplemented!(),
            }
        }
    }
}

impl LogTask {
    pub fn new(name: String, timedate: String) -> Self {
        Object::new(&[
                      ("name", &name),
                      ("timedate", &timedate)
        ]).expect("Failed to create `LogTask`.")
    }
}
