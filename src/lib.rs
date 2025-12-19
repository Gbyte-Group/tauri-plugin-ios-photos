use tauri::{
    plugin::{Builder, TauriPlugin},
    Manager, Runtime,
};

pub use models::*;

#[cfg(desktop)]
mod desktop;
#[cfg(mobile)]
mod mobile;

mod commands;
mod error;
mod models;

pub use error::{Error, Result};

#[cfg(desktop)]
use desktop::IosPhotos;
#[cfg(mobile)]
use mobile::IosPhotos;

/// Extensions to [`tauri::App`], [`tauri::AppHandle`] and [`tauri::Window`] to access the ios-photos APIs.
pub trait IosPhotosExt<R: Runtime> {
    fn ios_photos(&self) -> &IosPhotos<R>;
}

impl<R: Runtime, T: Manager<R>> crate::IosPhotosExt<R> for T {
    fn ios_photos(&self) -> &IosPhotos<R> {
        self.state::<IosPhotos<R>>().inner()
    }
}

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_photos);

/// Initializes the plugin.
pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-photos")
        .invoke_handler(tauri::generate_handler![commands::ping])
        .setup(|app, api| {
            #[cfg(mobile)]
            let ios_photos = mobile::init(app, api)?;
            #[cfg(desktop)]
            let ios_photos = desktop::init(app, api)?;
            app.manage(ios_photos);
            Ok(())
        })
        .build()
}
