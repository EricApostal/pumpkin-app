use pumpkin::{self, PumpkinServer};

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

pub async fn run_pumpkin() {
    let server = PumpkinServer::new().await.unwrap();
    server.start().await.unwrap();
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
