use serde::de::DeserializeOwned;
use tauri::{
    plugin::{PluginApi, PluginHandle},
    AppHandle, Runtime,
};

use crate::models::*;

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_ios_photos);

// initializes the Kotlin or Swift plugin classes
pub fn init<R: Runtime, C: DeserializeOwned>(
    _app: &AppHandle<R>,
    api: PluginApi<R, C>,
) -> crate::Result<IosPhotos<R>> {
    #[cfg(target_os = "android")]
    let handle = api.register_android_plugin("", "ExamplePlugin")?;
    #[cfg(target_os = "ios")]
    let handle = api.register_ios_plugin(init_plugin_ios_photos)?;
    Ok(IosPhotos(handle))
}

/// Access to the recently-deleted APIs.
pub struct IosPhotos<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> IosPhotos<R> {
    pub async fn request_photos_auth(&self) -> crate::Result<RequestPhotosAuthResponse> {
        self.0
            .run_mobile_plugin_async("requestPhotosAuth", ())
            .await
            .map_err(Into::into)
    }

    pub async fn get_photos_auth_status(&self) -> crate::Result<GetPhotosAuthStatusResponse> {
        self.0
            .run_mobile_plugin_async("getPhotosAuthStatus", ())
            .await
            .map_err(Into::into)
    }

    pub async fn request_albums(
        &self,
        payload: RequestAlbumsRequest,
    ) -> crate::Result<RequestAlbumsResponse> {
        self.0
            .run_mobile_plugin_async("requestAlbums", payload)
            .await
            .map_err(Into::into)
    }

    pub async fn request_album_medias(
        &self,
        payload: RequestAlbumMediasRequest,
    ) -> crate::Result<RequestAlbumMediasResponse> {
        self.0
            .run_mobile_plugin_async("requestAlbumMedias", payload)
            .await
            .map_err(Into::into)
    }

    pub async fn check_album_can_operation(
        &self,
        payload: CheckAlbumCanOperationRequest,
    ) -> crate::Result<CheckAlbumCanOperationResponse> {
        self.0
            .run_mobile_plugin_async("checkAlbumCanOperation", payload)
            .await
            .map_err(Into::into)
    }

    pub async fn create_album(
        &self,
        payload: CreateAlbumRequest,
    ) -> crate::Result<CreateAlbumResponse> {
        self.0
            .run_mobile_plugin_async("createAlbum", payload)
            .await
            .map_err(Into::into)
    }

    pub async fn create_photos(
        &self,
        payload: CreateMediaRequest,
    ) -> crate::Result<CreateMediaResponse> {
        self.0
            .run_mobile_plugin_async("createPhotos", payload)
            .await
            .map_err(Into::into)
    }

    pub async fn create_videos(
        &self,
        payload: CreateMediaRequest,
    ) -> crate::Result<CreateMediaResponse> {
        self.0
            .run_mobile_plugin_async("createVideos", payload)
            .await
            .map_err(Into::into)
    }
}
