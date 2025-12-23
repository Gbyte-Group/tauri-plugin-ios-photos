const COMMANDS: &[&str] = &[
  "request_photos_auth",
  "request_albums",
  "request_album_medias",
];

fn main() {
  tauri_plugin::Builder::new(COMMANDS)
    .android_path("android")
    .ios_path("ios")
    .build();
}
