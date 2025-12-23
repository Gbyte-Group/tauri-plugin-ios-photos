use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Default, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct AlbumItem {
    pub id: String,
    pub name: String,
}

#[derive(Debug, Clone, Default, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct MediaItem {
    pub id: String,
    pub media_type: isize,
    pub create_at: f32,
    pub data: Option<String>,
}

// #[derive(Debug, Clone, Default, Deserialize, Serialize)]
// #[serde(rename_all = "camelCase")]
// pub struct RequestPhotosAuthRequest {}

#[derive(Debug, Clone, Default, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct RequestPhotosAuthResponse {
    pub value: isize,
}

#[derive(Debug, Clone, Default, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct RequestAlbumsResponse {
    pub value: Vec<AlbumItem>,
}

#[derive(Debug, Clone, Default, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct RequestAlbumMediasRequest {
    pub id: String,
    pub height: isize,
    pub width: isize,
    pub quality: f64,
}

#[derive(Debug, Clone, Default, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct RequestAlbumMediasResponse {
    pub value: Vec<MediaItem>,
}
