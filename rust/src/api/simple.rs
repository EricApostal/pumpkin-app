use parking_lot::Mutex;
use pumpkin::{self, command};
use std::env;
use std::sync::{Arc, LazyLock};

static SERVER_INSTANCE: LazyLock<Arc<Mutex<Option<Arc<pumpkin::PumpkinServer>>>>> =
    LazyLock::new(|| Arc::new(Mutex::new(None)));

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

pub async fn start_server(app_dir: String) {
    if let Err(e) = env::set_current_dir(&app_dir) {
        eprintln!("Failed to set current directory: {}", e);
        return;
    }

    let pumpkin_server = Arc::new(pumpkin::PumpkinServer::new().await);
    pumpkin_server.init_plugins().await;

    {
        let mut server_guard = SERVER_INSTANCE.lock();
        *server_guard = Some(pumpkin_server.clone());
    }

    pumpkin_server.start().await;

    {
        let mut server_guard = SERVER_INSTANCE.lock();
        *server_guard = None;
    }
}

pub fn get_server() -> Option<Arc<pumpkin::PumpkinServer>> {
    SERVER_INSTANCE.lock().clone()
}

pub fn is_server_running() -> bool {
    SERVER_INSTANCE.lock().is_some()
}

pub async fn run_in_console(command: String) {
    if let Some(server) = get_server() {
        let dispatcher = server.server.command_dispatcher.read().await;
        dispatcher
            .handle_command(
                &mut command::CommandSender::Console,
                &server.server,
                &command,
            )
            .await;
    }
}

pub fn stop_server() {
    pumpkin::stop_server();
    let mut server_guard = SERVER_INSTANCE.lock();
    *server_guard = None;
}

pub async fn get_server_info() -> Option<String> {
    if let Some(server) = get_server() {
        Some(format!(
            "Server is running with {} players",
            server.server.get_all_players().await.len()
        ))
    } else {
        None
    }
}

pub async fn get_player_count() -> i32 {
    if let Some(server) = get_server() {
        server.server.get_all_players().await.len() as i32
    } else {
        0
    }
}
