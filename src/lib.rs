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
mod protocol;

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

/// Initializes the plugin.
pub fn init<R: Runtime>() -> TauriPlugin<R> {
    Builder::new("ios-photos")
        .invoke_handler(tauri::generate_handler![
            commands::request_photos_auth,
            commands::get_photos_auth_status,
            commands::request_albums,
            commands::request_album_medias,
            commands::check_album_can_operation,
        ])
        .setup(|app, api| {
            #[cfg(mobile)]
            let ios_photos = mobile::init(app, api)?;
            #[cfg(desktop)]
            let ios_photos = desktop::init(app, api)?;
            app.manage(ios_photos);
            Ok(())
        })
        .register_uri_scheme_protocol(protocol::CUSTOM_PROTOCOL, protocol::register_protocol)
        .build()
}
