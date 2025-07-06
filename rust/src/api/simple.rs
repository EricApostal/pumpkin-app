use pumpkin::{self, command, PumpkinServer as InternalPumpkinServer};
use std::env;
use std::sync::{Arc, OnceLock};

static PLUGINS_INITIALIZED: OnceLock<()> = OnceLock::new();

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

pub struct PumpkinServer {
    internal: Arc<InternalPumpkinServer>,
}

impl PumpkinServer {
    pub async fn new(app_dir: String) -> Result<Self, String> {
        if let Err(e) = env::set_current_dir(&app_dir) {
            return Err(format!("Failed to set current directory: {}", e));
        }

        let internal_server = Arc::new(InternalPumpkinServer::new().await);

        // Only initialize plugins once globally
        // PLUGINS_INITIALIZED.get_or_init(|| {
        //     futures::executor::block_on(async {
        //         internal_server.init_plugins().await;
        //     });
        // });

        Ok(Self {
            internal: internal_server,
        })
    }

    pub async fn start(&self) {
        self.internal.start().await;
    }

    pub async fn run_command(&self, command: String) -> Result<(), String> {
        let dispatcher = self.internal.server.command_dispatcher.read().await;
        dispatcher
            .handle_command(
                &mut command::CommandSender::Console,
                &self.internal.server,
                &command,
            )
            .await;
        Ok(())
    }

    pub fn stop(&self) {
        pumpkin::stop_server();
    }

    pub async fn get_info(&self) -> String {
        format!(
            "Server is running with {} players",
            self.internal.server.get_all_players().await.len()
        )
    }

    pub async fn get_player_count(&self) -> i32 {
        self.internal.server.get_all_players().await.len() as i32
    }
}
