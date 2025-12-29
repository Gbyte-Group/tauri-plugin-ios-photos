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
    // pub fn ping(&self, payload: PingRequest) -> crate::Result<PingResponse> {
    //   Ok(PingResponse {
    //     value: payload.value,
    //   })
    // }
    pub async fn request_photos_auth(&self) -> crate::Result<RequestPhotosAuthResponse> {
        Err(crate::Error::from(std::io::Error::other(
            "iOS Photos Not Supported This Platform.",
        )))
    }
    pub async fn get_photos_auth_status(&self) -> crate::Result<GetPhotosAuthStatusResponse> {
        Err(crate::Error::from(std::io::Error::other(
            "iOS Photos Not Supported This Platform.",
        )))
    }
    pub async fn request_albums(
        &self,
        _payload: RequestAlbumsRequest,
    ) -> crate::Result<RequestAlbumsResponse> {
        Err(crate::Error::from(std::io::Error::other(
            "iOS Photos Not Supported This Platform.",
        )))
    }
    pub async fn request_album_medias(
        &self,
        _payload: RequestAlbumMediasRequest,
    ) -> crate::Result<RequestAlbumMediasResponse> {
        Err(crate::Error::from(std::io::Error::other(
            "iOS Photos Not Supported This Platform.",
        )))
    }
    pub async fn check_album_can_operation(
        &self,
        _payload: CheckAlbumCanOperationRequest,
    ) -> crate::Result<CheckAlbumCanOperationResponse> {
        Err(crate::Error::from(std::io::Error::other(
            "iOS Photos Not Supported This Platform.",
        )))
    }
    pub async fn create_album(
        &self,
        _payload: CreateAlbumRequest,
    ) -> crate::Result<CreateAlbumResponse> {
        Err(crate::Error::from(std::io::Error::other(
            "iOS Photos Not Supported This Platform.",
        )))
    }
    pub async fn create_photos(
        &self,
        _payload: CreateMediaRequest,
    ) -> crate::Result<CreateMediaResponse> {
        Err(crate::Error::from(std::io::Error::other(
            "iOS Photos Not Supported This Platform.",
        )))
    }
    pub async fn create_videos(
        &self,
        _payload: CreateMediaRequest,
    ) -> crate::Result<CreateMediaResponse> {
        Err(crate::Error::from(std::io::Error::other(
            "iOS Photos Not Supported This Platform.",
        )))
    }
    pub async fn delete_album(
        &self,
        _payload: DeleteAlbumsRequest,
    ) -> crate::Result<DeleteAlbumsResponse> {
        Err(crate::Error::from(std::io::Error::other(
            "iOS Photos Not Supported This Platform.",
        )))
    }
    pub async fn delete_album_medias(
        &self,
        _payload: DeleteAlbumMediasRequest,
    ) -> crate::Result<DeleteAlbumMediasResponse> {
        Err(crate::Error::from(std::io::Error::other(
            "iOS Photos Not Supported This Platform.",
        )))
    }
    pub async fn remove_album_medias(
        &self,
        _payload: DeleteAlbumMediasRequest,
    ) -> crate::Result<DeleteAlbumMediasResponse> {
        Err(crate::Error::from(std::io::Error::other(
            "iOS Photos Not Supported This Platform.",
        )))
    }
}
