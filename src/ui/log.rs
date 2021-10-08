use std::rc::Rc;
use std::cell::RefCell;
use gtk::subclass::prelude::*;
use gtk::{glib};
use glib::Object;

#[derive(Default)]
pub struct LogTaskData {
    pub name: String,
    pub timedate: String,
}

glib::wrapper! {
    pub struct LogTask(ObjectSubclass<imp::LogTask>);
}

mod imp {
    use super::*;

    // Object holding the state
    #[derive(Default)]
    pub struct LogTask {
        pub data: Rc<RefCell<LogTaskData>>,
    }

    // The central trait for subclassing a GObject
    #[glib::object_subclass]
    impl ObjectSubclass for LogTask {
        const NAME: &'static str = "LogTask";
        type Type = super::LogTask;
        type ParentType = glib::Object;
    }

    impl ObjectImpl for LogTask {}
}

impl LogTask {
    pub fn new(name: String, timedate: String) -> Self {
        Object::new(&[
                      ("name", &name),
                      ("timedate", &timedate)
                     ]).expect("Failed to create `LogTask`.")
    }
}
