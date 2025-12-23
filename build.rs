const COMMANDS: &[&str] = &[
    "request_photos_auth",
    "request_albums",
    "request_album_medias",
    "check_album_can_operation",
    "get_photos_auth_status",
];

fn main() {
    tauri_plugin::Builder::new(COMMANDS)
        .android_path("android")
        .ios_path("ios")
        .build();
}
