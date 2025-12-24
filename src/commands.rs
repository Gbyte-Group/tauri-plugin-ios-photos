use tauri::{command, AppHandle, Runtime};

use crate::models::*;
use crate::IosPhotosExt;
use crate::Result;

#[command]
pub(crate) async fn request_photos_auth<R: Runtime>(
    app: AppHandle<R>,
    // payload: RequestPhotosAuthRequest,
) -> Result<RequestPhotosAuthResponse> {
    app.ios_photos().request_photos_auth().await
}

#[command]
pub(crate) async fn get_photos_auth_status<R: Runtime>(
    app: AppHandle<R>,
) -> Result<GetPhotosAuthStatusResponse> {
    app.ios_photos().get_photos_auth_status().await
}

#[command]
pub(crate) async fn request_albums<R: Runtime>(
    app: AppHandle<R>,
    payload: RequestAlbumsRequest,
) -> Result<RequestAlbumsResponse> {
    app.ios_photos().request_albums(payload).await
}

#[command]
pub(crate) async fn request_album_medias<R: Runtime>(
    app: AppHandle<R>,
    payload: RequestAlbumMediasRequest,
) -> Result<RequestAlbumMediasResponse> {
    app.ios_photos().request_album_medias(payload).await
}

#[command]
pub(crate) async fn check_album_can_operation<R: Runtime>(
    app: AppHandle<R>,
    payload: CheckAlbumCanOperationRequest,
) -> Result<CheckAlbumCanOperationResponse> {
    app.ios_photos().check_album_can_operation(payload).await
}

#[command]
pub(crate) async fn create_album<R: Runtime>(
    app: AppHandle<R>,
    payload: CreateAlbumRequest,
) -> Result<CreateAlbumResponse> {
    app.ios_photos().create_album(payload).await
}

#[command]
pub(crate) async fn create_photos<R: Runtime>(
    app: AppHandle<R>,
    payload: CreateMediaRequest,
) -> Result<CreateMediaResponse> {
    app.ios_photos().create_photos(payload).await
}

#[command]
pub(crate) async fn create_videos<R: Runtime>(
    app: AppHandle<R>,
    payload: CreateMediaRequest,
) -> Result<CreateMediaResponse> {
    app.ios_photos().create_videos(payload).await
}
