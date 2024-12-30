use pumpkin::{self, main};

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

// #[flutter_rust_bridge::frb()]
pub async fn run_pumpkin() {
    print!("Starting Pumpkin server...");
    main();
    // tokio::spawn(async {
    //     main().await;
    // });
    // let server = PumpkinServer::new().await.unwrap();
    // println!("Pumpkin server started!");
    // server.start().await.unwrap();
}

// pub async fn send_command(command: String) {
//     let server = PumpkinServer::new().await.unwrap();
//     server.send_command(command).await.unwrap();
// }

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
