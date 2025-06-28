use pumpkin;
use std::env;

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

pub async fn start_server(app_dir: String) {
    env::set_current_dir(&app_dir);
    let pumpkin_server = pumpkin::PumpkinServer::new().await;
    pumpkin_server.init_plugins().await;

    pumpkin_server.start().await;
}
