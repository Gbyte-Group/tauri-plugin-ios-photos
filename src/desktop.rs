use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};

use crate::models::*;

pub fn init<R: Runtime, C: DeserializeOwned>(
  app: &AppHandle<R>,
  _api: PluginApi<R, C>,
) -> crate::Result<IosPhotos<R>> {
  Ok(IosPhotos(app.clone()))
}

/// Access to the ios-photos APIs.
pub struct IosPhotos<R: Runtime>(AppHandle<R>);

impl<R: Runtime> IosPhotos<R> {
  pub fn ping(&self, payload: PingRequest) -> crate::Result<PingResponse> {
    Ok(PingResponse {
      value: payload.value,
    })
  }
}
