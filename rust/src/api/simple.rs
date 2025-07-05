use log::{Log, Metadata, Record, SetLoggerError};
use pumpkin;
use std::env;

use crate::frb_generated::StreamSink;
use log::Level;
use std::sync::Mutex;

struct CustomLogger {
    sink: Mutex<Option<StreamSink<String>>>,
}

impl CustomLogger {
    const fn new() -> Self {
        CustomLogger {
            sink: Mutex::new(None),
        }
    }

    fn set_sink(&self, sink: StreamSink<String>) {
        *self.sink.lock().unwrap() = Some(sink);
    }
}

impl Log for CustomLogger {
    fn enabled(&self, metadata: &Metadata) -> bool {
        metadata.level() <= Level::Info // Capture logs up to Info level; adjust as needed
    }

    fn log(&self, record: &Record) {
        if self.enabled(record.metadata()) {
            let message = format!("{}", record.args());
            if let Some(sink) = self.sink.lock().unwrap().as_ref() {
                sink.add(message);
            }
        }
    }

    fn flush(&self) {}
}

// Define the logger as a static variable
static LOGGER: CustomLogger = CustomLogger::new();

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[flutter_rust_bridge::frb]
pub fn setup_log_stream(sink: StreamSink<String>) {
    LOGGER.set_sink(sink);
}

pub fn init_logger() -> Result<(), SetLoggerError> {
    log::set_logger(&LOGGER)?;
    log::set_max_level(log::LevelFilter::Info);
    Ok(())
}

pub async fn start_server(app_dir: String) {
    env::set_current_dir(&app_dir);
    // init_logger().expect("Failed to initialize logger"); // Set up the logger
    let pumpkin_server = pumpkin::PumpkinServer::new().await;
    pumpkin_server.init_plugins().await;
    pumpkin_server.start().await;
}
